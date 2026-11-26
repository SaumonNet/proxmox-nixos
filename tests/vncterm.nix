{
  name = "pve-vncterm";

  nodes.mypve =
    { pkgs, ... }:
    let
      python = pkgs.python3.withPackages (ps: [ ps.proxmoxer ps.pygobject3 ]);
      client = pkgs.runCommand "vncterm-test-client" {
        nativeBuildInputs = [ pkgs.makeWrapper pkgs.gobject-introspection ];
        buildInputs = [ pkgs.gtk-vnc pkgs.gtk3 ];
      } ''
        makeWrapper ${python}/bin/python3 "$out/bin/test-vncterm" \
          --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
          --add-flags ${./vncterm.py}
      '';
    in
    {
      services.proxmox-ve = {
        enable = true;
        ipAddress = "192.168.1.1";
      };
      users.users.root = {
        password = "console-test";
        initialPassword = null;
        hashedPassword = null;
        hashedPasswordFile = null;
      };
      virtualisation.memorySize = 2048;
      environment.systemPackages = [ client ];
    };

  testScript = ''
    mypve.start()
    mypve.wait_for_unit("pveproxy.service")

    with subtest("Open a TLS console and run a shell command"):
        mypve.succeed("timeout 30 test-vncterm")

    with subtest("Reject an invalid console ticket"):
        mypve.succeed("timeout 30 test-vncterm --invalid-ticket")
  '';
}
