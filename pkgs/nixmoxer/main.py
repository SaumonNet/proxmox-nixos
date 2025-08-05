from proxmoxer import ProxmoxAPI
import click
import json
import logging
import os
import requests_toolbelt
import subprocess
import sys
import time
import urllib3

logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


class Proxmox:
    """
    A class to interact with the Proxmox API to manage virtual machines, storage, and volumes.
    """

    def __init__(self, api):
        """
        Initialize the Proxmox class with an API instance.

        Args:
            api (ProxmoxAPI): An instance of the ProxmoxAPI to interact with the Proxmox server.
        """
        self.api = api

    def list_vms_on_cluster(self):
        """
        List all virtual machines (VMs) available on the cluster.

        Returns:
            list: A list of tuples where each tuple contains the VM ID and the VM name.
        """
        vms = []
        nodes = self.api.nodes.get()
        for node in nodes:
            if node["status"] == "online":
                node_name = node["node"]
                vms_node = self.api.nodes(node_name).qemu.get()
                vms += list(map(lambda x: (x["vmid"],
                            x["name"], node_name), vms_node))
        return vms

    def iso_exists(self, node, storage, iso):
        """
        Check if a specific ISO file exists in a storage on a node.

        Args:
            node (str): The name of the node.
            storage (str): The name of the storage.
            iso (str): The name of the ISO file.

        Returns:
            bool: True if the ISO file exists, False otherwise.
        """
        volumes = self.api.nodes(node).storage(storage).content.get()
        return f"{storage}:iso/{iso}" in map(lambda x: x["volid"], volumes)

    def upload_iso(self, node, storage, iso):
        """
        Upload an ISO file to a specific storage on a node.

        Args:
            node (str): The name of the node.
            storage (str): The name of the storage.
            iso (file): The ISO file to upload.

        Raises:
            ValueError: If the storage does not exist or the ISO already exists.
        """
        iso_name = os.path.basename(iso)
        if self.iso_exists(node, storage, iso_name):
            logging.error(click.style(
                f'The specified iso already exists on {node}/local.', fg='red'))
            logging.info(click.style(
                'Do you wish to destroy it?', fg='yellow'))
            verify_before_destructive_action("yes")
            self.delete_iso(node, storage, iso_name)


        logging.info(click.style(
            f'Uploading iso "{iso_name}" to "{node}/{storage}"...', fg='cyan'))

        self.api.nodes(node).storage(storage).upload.create(
            content="iso",
            filename=open(iso, "rb"),
        )

        expected_size = os.path.getsize(iso)
        current_size = 0
        logging.info(click.style("Waiting for full upload...", fg="cyan"))
        while current_size != expected_size:
            time.sleep(0.5)
            volume = (
                self.api.nodes(node)
                .storage(storage)
                .content(f"{storage}:iso/{iso_name}")
                .get()
            )
            current_size = volume["size"]

    def delete_iso(self, node, storage, iso):
        """
        Delete an ISO file to a specific storage on a node.

        Args:
            node (str): The name of the node.
            storage (str): The name of the storage.
            iso (file): The ISO file to delete.

        Raises:
            ValueError: ISO does not exist.
        """
        iso_name = os.path.basename(iso)
        logging.warn(click.style(
            f'Deleting iso "{iso_name}" from "{node}/{storage}"...', fg='yellow'))

        if not self.iso_exists(node, storage, iso_name):
            logging.error(click.style(
                f'The iso "{iso_name}" does not exist on storage "{storage}" on node "{node}".', fg='red'))
            raise ValueError(
                f'The iso "{iso_name}" does not exist on storage "{storage}" on node "{node}".')

        self.api.nodes(node).storage(storage).content(f"iso/{iso_name}").delete(
            node=node,
        )
        logging.info(click.style(
            f'Successfully deleted iso "{iso_name}" from "{node}/{storage}".', fg='green'))

    def find_free_vmid(self):
        """
        Find the next available VM ID on the cluster.

        Returns:
            int: The next available VM ID.
        """
        vms = self.list_vms_on_cluster()
        if not vms:
            return 100
        ids, _, _ = zip(*vms)
        return max(ids) + 1

    def vmid_exists(self, vmid):
        """
        Check if a VM ID already exists on the cluster.

        Args:
            vmid (int): The VM ID to check.

        Returns:
            bool: True if the VM ID exists, False otherwise.
        """
        vms = self.list_vms_on_cluster()
        if (len(vms) == 0):
            return False, None, None
        ids, names, nodes = zip(*vms)
        if vmid in ids:
            index = ids.index(vmid)
            return True, names[index], nodes[index]
        return False, None, None

    def vm_name_exists(self, vm_name):
        """
        Check if a VM ID already exists on the cluster.

        Args:
            vmid (int): The VM ID to check.

        Returns:
            bool: True if the VM ID exists, False otherwise.
        """
        vms = self.list_vms_on_cluster()
        if (len(vms) == 0):
            return False, None, None
        ids, names, nodes = zip(*vms)
        if vm_name in names:
            index = names.index(vm_name)
            return True, ids[index], nodes[index]
        return False, None, None

    def destroy_vm(self, vmid, node):
        """
        Destroy a VM on a specified node.

        Args:
            vmid (str): The VM ID.
            node (str): The name of the node.
        """
        logging.info(click.style(
            f'Stopping VM "{vmid}" on node "{node}"...', fg='yellow'))

        self.api.nodes(node).qemu(vmid).status.stop.post(node=node)

        status = "running"
        for _ in range(10):
            status = self.api.nodes(node).qemu(
                vmid).status.current.get()["status"]
            if status == "stopped":
                break
            time.sleep(1)

        if status == "running":
            logging.error(click.style(
                "The VM did not stop in time.", fg='red'))
            sys.exit(1)

        logging.info(click.style(
            f'Deleting VM "{vmid}" on node "{node}"...', fg='yellow'))
        self.api.nodes(node).qemu(vmid).delete(node=node)
        logging.info(click.style(
            f'Successfully destroyed VM "{vmid}" on node "{node}".', fg='green'))

    def create_vm(self, node, config):
        """
        Create a new virtual machine (VM) with the specified configuration.

        Args:
            node (str): The name of the node.
            config (dict): The configuration for the new VM.

        Raises:
            ValueError: If the specified VM ID already exists.
        """
        api_params = config_to_api_params(config)

        logging.info(click.style('Configuration:\n' +
                     json.dumps(api_params, indent=2), fg='cyan'))

        if "vmid" not in api_params.keys():
            logging.info(click.style(
                'No VM ID set. Finding the smallest free VM ID...', fg='cyan'))
            api_params["vmid"] = int(self.find_free_vmid())
            logging.info(click.style(
                f'Set VM ID to "{api_params["vmid"]}."', fg='green'))

        vmid_exists, name, vm_node = self.vmid_exists(
            int(api_params["vmid"]))
        if vmid_exists:
            logging.warning(click.style(
                f'The VM "{name}" already exists on the cluster with this ID, do you want to destroy it?\n'
                'WARNING: This is irreversible and will delete associated disks.\n'
                'Type the VM name to confirm deletion:', fg='yellow'
            ))
            verify_before_destructive_action(name)
            self.destroy_vm(api_params["vmid"], vm_node)

        time.sleep(1)

        vm_name_exists, vmid, vm_node = self.vm_name_exists(
            api_params["name"])
        if vm_name_exists:
            logging.warning(click.style(
                f'The VM "{api_params["name"]}" already exists on the cluster with VM ID {vmid}, do you want to destroy it?\n'
                'WARNING: This is irreversible and will delete associated disks.\n'
                'Type the VM name to confirm deletion:', fg='yellow'
            ))
            verify_before_destructive_action(str(vmid))
            self.destroy_vm(api_params["vmid"], vm_node)

        logging.info(click.style(
            f'Creating VM "{api_params["name"]}" with VM ID {api_params["vmid"]} on node "{node}"...', fg='green'))
        self.api.nodes(node).qemu.create(**api_params)
        logging.info(click.style(
            f'Successfully created VM "{api_params["name"]}" on node "{node}".', fg='green'))


def eval_config(machine, flake):
    """
    Evaluate the NixOS configuration for a specific machine.

    Args:
        machine (str): The name of the machine.
        flake (bool): A flag indicating whether to use the Nix flake system.

    Returns:
        str: The JSON output of the evaluated NixOS configuration.
    """
    logging.info(click.style('Evaluating configuration...', fg='cyan'))

    try:
        result = subprocess.run(
            ["nix", "eval", "--json"]
            + ([] if flake else ["-f", "default.nix"])
            + [(".#" if flake else"")+f"nixosConfigurations.{machine}.config.virtualisation.proxmox"],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        logging.info(click.style(
            'Configuration evaluation completed successfully.', fg='green'))
        return result.stdout

    except subprocess.CalledProcessError as e:
        logging.error(click.style('Machine evaluation failed:', fg='red'))
        logging.error(click.style(e.stderr, fg='red'))
        sys.exit(1)


def build_iso(machine, flake):
    """
    Build the iso specified by the user

    Args:
        machine (str): The name of the machine.
        flake (bool): A flag indicating whether to use the Nix flake system.
    """

    logging.info(click.style('Building iso...', fg='cyan'))

    try:
        subprocess.run(
            ["nix", "--print-build-logs", "build"]
            + ([] if flake else ["-f", "default.nix"])
            + [(".#" if flake else "")+f"nixosConfigurations.{machine}.config.virtualisation.proxmox.iso"],
            check=True,
            stdout=sys.stdout,
            stderr=sys.stderr,
            text=True
        )
        logging.info(click.style(
            'Iso built successfully.', fg='green'))

    except subprocess.CalledProcessError as e:
        logging.error(click.style('ISO building failed.', fg='red'))
        logging.error(click.style(e.stderr, fg='red'))
        sys.exit(1)


def find_iso(path):
    """
    Find the iso file path inside the output folder
    """
    iso_folder = os.path.join(path, "iso")

    if not os.path.exists(iso_folder):
        logging.error(click.style(
            f"The folder '{iso_folder}' does not exist.", fg='red'))
        return None

    files = os.listdir(iso_folder)
    logging.info(click.style(f"Files in '{iso_folder}': {files}", fg='cyan'))

    iso_files = [file for file in files if os.path.isfile(
        os.path.join(iso_folder, file))]

    return iso_files[0] if iso_files else None


def verify_before_destructive_action(confirmation):
    """
    Prompt the user to confirm a potentially destructive action.

    Args:
        confirmation (str): The word the user must type to confirm the action.
    """
    logging.warning(click.style(
        f"To proceed, please type the word '{confirmation}':", fg='yellow'))

    while True:
        user_input = input(click.style(
            "Enter the confirmation word: ", fg='cyan')).strip()
        if user_input == confirmation:
            logging.info(click.style(
                "Action confirmed. Proceeding...", fg='green'))
            break
        else:
            logging.error(click.style(
                f"Incorrect input. You must type '{confirmation}' to confirm, or exit.", fg='red'))


def parse_configuration():
    """
    Parse configuration values from three possible sources in order of priority:
    1. Environment variables.
    2. Local directory configuration file 'nixmoxer.conf'.
    3. Configuration file located at '$XDG_CONFIG_HOME/nixmoxer.conf'.

    Returns:
        dict: A dictionary containing the configuration key-value pairs.
    """
    xdg_config_home = os.getenv(
        'XDG_CONFIG_HOME', os.path.expanduser('~/.config'))
    xdg_config_file_path = os.path.join(xdg_config_home, 'nixmoxer.conf')
    local_config_file_path = os.path.join(os.getcwd(), 'nixmoxer.conf')
    config = {}

    if os.path.exists(xdg_config_file_path):
        logging.info(click.style(
            f"Loading configuration from {xdg_config_file_path}...", fg='cyan'))
        config.update(read_config_file(xdg_config_file_path))

    if os.path.exists(local_config_file_path):
        logging.info(click.style(
            f"Loading configuration from {local_config_file_path}...", fg='cyan'))
        config.update(read_config_file(local_config_file_path))

    for key, value in os.environ.items():
        if key.startswith("PROXMOX_"):
            config_key = key[len("PROXMOX_"):]
            config[config_key.lower()] = value
            logging.info(click.style(
                f"Environment variable '{key}' loaded as '{config_key.lower()}'", fg='cyan'))

    # Validate required keys
    if "host" not in config.keys():
        logging.error(click.style(
            f'Missing authentication configuration for Proxmox. Please set "host" in {local_config_file_path}.', fg='red'))
        raise KeyError('Missing "host" configuration')

    if "user" not in config.keys():
        logging.error(click.style(
            f'Missing authentication configuration for Proxmox. Please set "user" in {local_config_file_path}.', fg='red'))
        raise KeyError('Missing "user" configuration.')

    if "password" not in config.keys() and ("token_name" not in config.keys() or "token_value" not in config.keys()):
        logging.error(click.style(
            'Missing authentication configuration for Proxmox. Please set either "password" or both "token_name" and "token_value".', fg='red'))
        raise KeyError(
            'Missing "password" or "token_name" and "token_value" configuration.')

    logging.info(click.style("Configuration parsed successfully.", fg='green'))
    return config


def read_config_file(file_path):
    """
    Read key-value pairs from a configuration file.

    Args:
        file_path (str): The path to the configuration file.

    Returns:
        dict: A dictionary containing key-value pairs from the file.
    """
    config = {}
    with open(file_path, 'r') as file:
        for line in file:
            line = line.strip()
            # Ignore empty lines and comments
            if line and not line.startswith('#') and '=' in line:
                key, value = line.split('=', 1)
                config[key.strip().lower()] = value.strip()
    return config


def config_to_api_params(config):
    """
    Map configuration dictionary to Proxmox API parameters, excluding None values and empty lists.
    Converts booleans to 0 or 1, transforms dictionaries to key=value strings, processes lists of dictionaries,
    and concatenates lists of strings.

    Args:
        config (dict): Configuration dictionary.

    Returns:
        dict: Filtered Proxmox API parameters.
    """
    def process_value(key, value):
        # Convert boolean to 0 or 1
        if isinstance(value, bool):
            return 1 if value else 0

        # Handle string "True" and "False" as booleans
        if isinstance(value, str):
            if value == "True":
                return 1
            elif value == "False":
                return 0

        # Convert dictionary to "key1=value1,key2=value2,..."
        if isinstance(value, dict):
            result = {k: process_value(k, v) for k, v in value.items() if v not in [
                None, {}, []]}
            return ','.join(f"{k}={v}" for k, v in result.items()) if result else None

        # Process list of strings by concatenating with a comma
        if isinstance(value, list):
            if all(isinstance(item, str) for item in value):
                concatenated = ','.join(value)
                return concatenated if concatenated else None

            # Process list of dictionaries and flatten the keys
            if all(isinstance(item, dict) for item in value):
                flattened = {}
                for i, item in enumerate(value):
                    result = process_value(f"{key}{i}", item)
                    if isinstance(result, str):
                        flattened[f"{key}{i}"] = result
                return flattened

            # Process list of other values (e.g., numbers) by concatenating with a comma
            if all(isinstance(item, (int, float)) for item in value):
                return ','.join(map(str, value)) if value else None

        # Filter out None or empty string values
        if value in [None, '']:
            return None

        # Return value directly if it's not a dict, list, None, or empty string
        return value

    api_params = {}
    for k, v in config.items():
        processed_value = process_value(k, v)
        if isinstance(processed_value, dict):
            # Merge flattened dictionaries with top level
            api_params.update(processed_value)
        elif processed_value is not None:
            api_params[k] = processed_value

    return api_params


def authenticate_promox():
    """
    Authenticate Proxmox using the config.
    """
    try:
        config = parse_configuration()

        if "token_name" in config.keys() and "token_value" in config.keys():
            logging.info(click.style(
                "Authenticating with token...", fg='cyan'))
            api = ProxmoxAPI(
                config["host"],
                user=config["user"],
                token_name=config["token_name"],
                token_value=config["token_value"],
                verify_ssl=bool(int(config.get("verify_ssl", True))),
                timeout=30
            )
        else:
            logging.info(click.style(
                "Authenticating with password...", fg='cyan'))
            api = ProxmoxAPI(
                config["host"],
                user=config["user"],
                password=config["password"],
                verify_ssl=bool(int(config.get("verify_ssl", True))),
                timeout=30
            )

        logging.info(click.style("Authentication successful.", fg='green'))
        return Proxmox(api)

    except KeyError as e:
        logging.error(click.style(
            f"Authentication failed:\n {str(e)}", fg='red'))
        sys.exit(1)

@click.command()
@click.option('--flake', is_flag=True)
@click.argument('machine')
def bootstrap(flake, machine):
    """
    Bootstrap the NixOS configuration for a specific machine using Nix flake or non-flake.

    Args:
        flake (bool): A flag indicating whether to use the Nix flake system.
        machine (str): The name of the machine to bootstrap.
    """
    proxmox = authenticate_promox()
    config = eval_config(machine, flake)
    config = json.loads(config)
    node = config['node']
    config.pop('autoInstall', None)

    build_iso(machine, flake)
    iso_file = find_iso(config["iso"])
    proxmox.upload_iso(node, "local", config["iso"]+f"/iso/{iso_file}")
    config["cdrom"] = f"local:iso/{iso_file}"

    config.pop('iso', None)
    proxmox.create_vm(node, config)
    logging.info(click.style("Virtual machine successfully created!", fg='green'))


def run_main():
    """
    Entry point to run the main program logic, starting with the bootstrap command.
    """
    bootstrap()
