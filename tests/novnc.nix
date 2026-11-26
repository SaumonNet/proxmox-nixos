{
  name = "pve-novnc";

  nodes.mypve =
    { pkgs, ... }:
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

      environment.variables.PLAYWRIGHT_BROWSERS_PATH = pkgs.playwright-driver.browsers-chromium;
      environment.systemPackages = [
        (pkgs.writers.writePython3Bin "test-novnc" {
          libraries = [ pkgs.python3Packages.playwright ];
        } ./novnc.py)
      ];
    };

  testScript = ''
    mypve.start()
    mypve.wait_for_unit("pveproxy.service")
    mypve.succeed("test-novnc")
    mypve.succeed("test -e /tmp/novnc-ok")
  '';
}
