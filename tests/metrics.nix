{
  name = "pve-metrics";

  nodes.mypve = { pkgs, ... }: {
    services.proxmox-ve = {
      enable = true;
      ipAddress = "192.168.1.1";
    };
    virtualisation.memorySize = 2048;
    environment.systemPackages = [ pkgs.jq ];
  };

  testScript = ''
    mypve.start()
    mypve.wait_for_unit("pvestatd.service")

    with subtest("The node records CPU and memory usage"):
        # The hourly graph reports one sample per minute.
        mypve.wait_until_succeeds(
            "pvesh get /nodes/mypve/rrddata --timeframe hour --output-format json"
            " | jq -e 'any(.[]; .time >= now - 180"
            " and (.cpu | type == \"number\") and (.memused | type == \"number\"))'",
            timeout=180,
        )
  '';
}
