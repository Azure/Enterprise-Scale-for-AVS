# VMware Ubuntu VM

Creates an Ubuntu virtual machine by cloning an existing vSphere template. The
module resolves the datacenter, compute cluster, datastore, networks, and template
by name. The VM can connect to between one and seven distinct network segments.
Cloud-init metadata and user-data are delivered through VMware
GuestInfo using base64 encoding.

The source template must:

- Be an Ubuntu template available through vCenter Server.
- Include VMware Tools or `open-vm-tools`.
- Include cloud-init with the VMware GuestInfo data source enabled.
- Not be an OVF/OVA template whose GuestInfo settings require vApp properties.

## Usage

Configure the vSphere provider in the calling module. Credentials can be supplied
with `VSPHERE_USER`, `VSPHERE_PASSWORD`, and `VSPHERE_SERVER`.

```hcl
provider "vsphere" {
  allow_unverified_ssl = false
}

module "ubuntu_vm" {
  source = "./modules/vmware"

  datacenter_name      = "dc-01"
  compute_cluster_name = "cluster-01"
  datastore_name       = "datastore-01"
  network_names = [
    "management",
    "segment-10100",
    "segment-10101",
  ]
  template_name        = "templates/ubuntu-24.04-cloud-init"
  vm_name              = "ubuntu-app-01"

  cloud_init_user_data = file("${path.module}/cloud-init/ubuntu-app.yaml")
}
```

Until the final cloud-init script is supplied, the default user-data is a valid
no-op document:

```yaml
#cloud-config
```

Changing `cloud_init_user_data` updates the GuestInfo value. Whether cloud-init
processes updated user-data on an existing VM depends on its instance state;
recreating the VM is the predictable way to rerun first-boot configuration.

## Inputs

| Name | Description | Default |
| --- | --- | --- |
| `datacenter_name` | vSphere datacenter name | required |
| `compute_cluster_name` | vSphere compute cluster name | required |
| `datastore_name` | vSphere datastore name | required |
| `network_names` | Ordered list of 1–7 distinct vSphere network names | required |
| `template_name` | Cloud-init-enabled Ubuntu template name or path | required |
| `vm_name` | VM name and cloud-init instance ID | required |
| `folder` | VM folder relative to the datacenter VM folder | `null` |
| `num_cpus` | Number of virtual CPUs | `2` |
| `memory_mb` | Memory in MiB | `4096` |
| `cloud_init_user_data` | Cloud-init user-data document | `#cloud-config` |
| `linked_clone` | Use a linked clone | `false` |
| `clone_timeout_minutes` | Clone timeout in minutes | `30` |
| `wait_for_guest_ip_timeout` | Guest IP timeout in minutes | `10` |
| `wait_for_guest_net_timeout` | Routable guest network timeout in minutes | `10` |

## Outputs

The module exports the VM UUID, managed object ID, name, VMX path, default IP
address, and all guest IP addresses reported by VMware Tools.
