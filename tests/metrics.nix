{
  name = "pve-metrics";

  nodes.mypve = { pkgs, ... }: {
    services.proxmox-ve = {
      enable = true;
      ipAddress = "192.168.1.1";
    };
    virtualisation.memorySize = 2048;
    environment.systemPackages = [ pkgs.jq pkgs.socat ];
  };

  testScript = ''
    mypve.start()
    mypve.wait_for_unit("pvestatd.service")

    with subtest("The cache receives metric updates before and after a restart"):
        check_updates = (
            "echo STATS | socat - UNIX-CONNECT:/run/rrdcached.sock"
            " | grep -E '^UpdatesReceived: [1-9][0-9]*$'"
        )
        mypve.wait_until_succeeds(check_updates, timeout=60)
        mypve.succeed("systemctl restart rrdcached.service")
        mypve.wait_until_succeeds(check_updates, timeout=60)

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
