{
  name = "pve-iso-upload";

  nodes.mypve = {
    services.proxmox-ve = {
      enable = true;
      ipAddress = "192.168.1.1";
    };

    # root@pam authenticates against PAM, so the API needs a real password.
    users.users.root = {
      password = "mypassword";
      initialPassword = null;
      hashedPassword = null;
      hashedPasswordFile = null;
    };

    virtualisation.diskSize = 4096;
  };

  testScript = ''
    import json
    from urllib.parse import quote

    machine.start()
    machine.wait_for_unit("pveproxy.service")

    machine.succeed("dd if=/dev/urandom of=/tmp/test.iso bs=1M count=32")

    # Uploading an ISO from the web UI is just these API calls, so make them the
    # same way the UI does: log in for a ticket, then POST the file to the storage.
    auth = json.loads(
        machine.succeed(
            "curl -sSf -k"
            " -d username=root@pam"
            " --data-urlencode password=mypassword"
            " https://localhost:8006/api2/json/access/ticket"
        )
    )["data"]

    # PVE stores the ticket URL-escaped in the cookie and unescapes it on read.
    cookie = "PVEAuthCookie=" + quote(auth["ticket"], safe="")

    # The multipart parser reads 'content' before the file part and insists the
    # file field be named 'filename', so the order of the -F flags matters.
    machine.succeed(
        "curl -sSf -k"
        f" -b '{cookie}'"
        f" -H 'CSRFPreventionToken: {auth['CSRFPreventionToken']}'"
        " -F content=iso"
        " -F filename=@/tmp/test.iso"
        " https://localhost:8006/api2/json/nodes/mypve/storage/local/upload"
    )

    # The upload hands off to a background task, so the ISO shows up in the
    # storage listing - the same one the UI populates its ISO picker from -
    # a moment later.
    machine.wait_until_succeeds(
        "curl -sSf -k"
        f" -b '{cookie}'"
        " 'https://localhost:8006/api2/json/nodes/mypve/storage/local/content?content=iso'"
        " | grep -q local:iso/test.iso",
        timeout=120,
    )

    # An ISO that arrived corrupted would still be listed, so check the bytes.
    machine.succeed("cmp /tmp/test.iso /var/lib/vz/template/iso/test.iso")
  '';
}
