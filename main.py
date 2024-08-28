from proxmoxer import ProxmoxAPI
import urllib3
import os

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class Proxmox:
    def __init__(self, api):
        self.api = api

    def list_vms_on_cluster(self):
        vms = []
        nodes = self.api.nodes.get()
        for node in nodes:
            if node["status"] == "online":
                node_name = node["node"]
                vms_node = self.api.nodes(node_name).qemu.get()
                vms += list(map(lambda x: (x["vmid"], x["name"]), vms_node))
        return vms


    def storage_exists(self, node, storage):
        storages = self.api.nodes(node).storage.get()
        return storage in map(lambda x: x["storage"], storages)

    def iso_exists(self, node, storage, iso):
        volumes = self.api.nodes(node).storage(storage).content.get()
        return f"{storage}:iso/{iso}" in map(lambda x: x["volid"], volumes) 

    def upload_iso(self, node, storage, iso):
        iso_name = os.path.basename(iso.name)
        if not self.storage_exists(node, storage):
            raise ValueError(f"The storage {storage} does not exist on node {node}") 
        if self.iso_exists(node, storage, iso_name):
            raise ValueError(f'The iso "{iso_name}" already exists on storage "{storage}" on node "{node}"') 
        self.api.nodes(node).storage(storage).upload.create(
            content="iso",
            filename=iso,
            )

    def find_free_vmid(self):
        vms = self.list_vms_on_cluster()
        ids, _ = zip(*vms)
        return max(ids) + 1

    def vmid_exists(self, vmid):
        vms = self.list_vms_on_cluster()
        ids, _ = zip(*vms)
        return vmid in ids

    def volume_exists(self, node, storage, volume_name):
        volumes = self.api.nodes(node).storage(storage).content.get()
        return f"{storage}:{volume_name}" in map(lambda x: x["volid"], volumes) 


    def create_volume(self, node, storage, volume_name, volume_size, vmid):
        if self.volume_exists(node, storage, volume_name):
            raise ValueError(f'The volume "{volume_name}" already exists on storage "{storage}" on node "{node}') 

        self.api.nodes(node).storage(storage).content.post(
                filename=volume_name,
                node=node,
                size=volume_size,
                storage=storage,
                vmid=vmid
                )


    def create_vm(self, vmid=None):
        if vmid is not None and self.vmid_exists(vmid):
            raise ValueError(f'The specified vmid {vmid} already exists on the cluster')
        if vmid is None:
            vmid = self.find_free_vmid()

        pass
        
