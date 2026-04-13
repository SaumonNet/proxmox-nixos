{ lib, ... }:

let
  cluster = import ./cluster-common.nix { inherit lib; };
in
{
  name = "pve-cluster-api-conntrack";

  inherit (cluster) nodes;

  testScript = ''
    import json
    import re
    import shlex
    import urllib.parse

    ${cluster.clusterSetupScript}
    ${cluster.vmSetupScript}
    ${cluster.conntrackSetupScript}

    auth = json.loads(
      pve1.succeed(
        "curl -sk --data-urlencode username=root@pam --data-urlencode password=mypassword "
        "https://localhost:8006/api2/json/access/ticket"
      )
    )
    ticket = auth["data"]["ticket"]
    csrf = auth["data"]["CSRFPreventionToken"]

    def pve_api(method, path, data=None):
      cmd = ["curl", "-sk", "-X", method, "--cookie", f"PVEAuthCookie={ticket}"]
      if method != "GET":
        cmd += ["-H", f"CSRFPreventionToken: {csrf}"]
      if data is not None:
        for key, value in data.items():
          cmd += ["--data-urlencode", f"{key}={value}"]
      cmd.append(f"https://localhost:8006/api2/json{path}")
      return json.loads(pve1.succeed(" ".join(shlex.quote(arg) for arg in cmd)))["data"]

    upid = pve_api(
      "POST",
      "/nodes/pve1/qemu/${toString cluster.vmid}/migrate",
      {
        "target": "pve2",
        "online": 1,
        "with-local-disks": 1,
        "targetstorage": "local",
        "with-conntrack-state": 1,
      },
    )

    task_path = urllib.parse.quote(upid, safe="")
    while True:
      task_status = pve_api("GET", f"/nodes/pve1/tasks/{task_path}/status")
      if task_status["status"] == "stopped":
        break
      time.sleep(1)

    assert task_status["exitstatus"] == "OK", task_status
    task_log = pve_api("GET", f"/nodes/pve1/tasks/{task_path}/log")
    task_log_text = "\n".join(entry.get("t", "") for entry in task_log)
    assert re.search(r"migrated [1-9][0-9]* conntrack state entr", task_log_text), task_log_text

    ${cluster.clusterValidationScript}
    ${cluster.dbusVmstateValidationScript}
    ${cluster.conntrackValidationScript}
  '';
}
