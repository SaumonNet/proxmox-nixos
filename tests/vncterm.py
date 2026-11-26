"""Connect to the PVE host console with the headless GVnc client."""

import argparse
from pathlib import Path
import socket

import gi
from proxmoxer import ProxmoxAPI

gi.require_version("GVnc", "1.0")
gi.require_version("GtkVnc", "2.0")
from gi.repository import GLib, GVnc, GtkVnc


def wait_for(client, signal):
    events = []
    errors = []
    handler = client.connect(signal, lambda _, *args: events.append(args))
    on_error = client.connect("vnc-error", lambda _, reason: errors.append(reason))
    closed = client.connect("vnc-disconnected", lambda _: events.append(None))
    try:
        while not events:
            GLib.MainContext.default().iteration(True)
        if events[0] is None:
            raise RuntimeError(f"Disconnected waiting for {signal}: {errors}")
        return events[0]
    finally:
        client.disconnect(handler)
        client.disconnect(on_error)
        client.disconnect(closed)


def choices(values):
    return [values.get_nth(i) for i in range(values.n_values)]


def exercise_terminal(client):
    width, height = client.get_width(), client.get_height()
    framebuffer = GtkVnc.CairoFramebuffer.new(width, height, client.get_pixel_format())
    client.set_framebuffer(framebuffer)
    client.framebuffer_update_request(False, 0, 0, width, height)
    wait_for(client, "vnc-framebuffer-update")

    for key in [*map(ord, "touch /tmp/vncterm-ok"), 0xff0d]:  # Return
        client.key_event(True, key, 0)
        client.key_event(False, key, 0)
    # Key events are queued. Keep servicing the connection until the shell runs them.
    while not Path("/tmp/vncterm-ok").exists():
        GLib.MainContext.default().iteration(False)
        GLib.usleep(10000)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--invalid-ticket", action="store_true")
    args = parser.parse_args()

    node = socket.gethostname()
    ca = Path("/etc/pve/pve-root-ca.pem")
    api = ProxmoxAPI(node, user="root@pam", password="console-test", verify_ssl=str(ca))
    console = api.nodes(node).vncshell.post(websocket=0)
    client = GVnc.Connection.new()
    credential = GVnc.ConnectionCredential
    ticket = console["ticket"]
    if args.invalid_ticket:
        ticket += "x"
    client.set_credential(credential.USERNAME, console["user"])
    client.set_credential(credential.PASSWORD, ticket)
    client.set_credential(credential.CLIENTNAME, "vncterm-test")
    client.set_credential(credential.CA_CERT_DATA, ca.read_text())
    assert client.open_host(node, str(console["port"]))

    (offered,) = wait_for(client, "vnc-auth-choose-type")
    auth_types = choices(offered)
    assert GVnc.ConnectionAuth.NONE not in auth_types, "Anonymous access offered"
    assert GVnc.ConnectionAuth.VENCRYPT in auth_types, "VeNCrypt unavailable"
    client.set_auth_type(GVnc.ConnectionAuth.VENCRYPT)
    _, subtypes = wait_for(client, "vnc-auth-choose-subtype")
    assert GVnc.ConnectionAuthVencrypt.X509PLAIN in choices(subtypes)
    client.set_auth_subtype(GVnc.ConnectionAuthVencrypt.X509PLAIN)

    if args.invalid_ticket:
        (reason,) = wait_for(client, "vnc-auth-failure")
        assert reason == "Authentication failed", reason
    else:
        wait_for(client, "vnc-initialized")
        exercise_terminal(client)
    client.shutdown()


if __name__ == "__main__":
    main()
