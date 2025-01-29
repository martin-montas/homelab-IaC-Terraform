terraform {
  required_version = ">= 0.13.0"

  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.endpoint
  pm_api_token_id = var.api_token
  pm_api_token_secret = var.secret
  pm_tls_insecure = true  # <-- (Optional) Change to true if you are using self-signed certificates

}

resource "proxmox_vm_qemu" "your-vm" {
  
  # -- General settings

  name = "vm-name"
  desc = "just a test"
  agent = 1  # <-- (Optional) Enable QEMU Guest Agent
  target_node = "pve"  # <-- Change to the name of your Proxmox node (if you have multiple nodes)
  tags = "test"
  vmid = "100"

  # -- Template settings

  clone = "Ubuntu-22.04-template"  # <-- Change to the name of the template or VM you want to clone
  full_clone = true  # <-- (Optional) Set to "false" to create a linked clone

  # -- Boot Process

  onboot = true 
  startup = ""  # <-- (Optional) Change startup and shutdown behavior
  automatic_reboot = false  # <-- Automatically reboot the VM after config change

  # -- Hardware Settings

  qemu_os = "other"
  bios = "ovmf"
  cores = 2
  sockets = 1
  cpu_type = "host"
  memory = 2048
  balloon = 2048  # <-- (Optional) Minimum memory of the balloon device, set to 0 to disable ballooning
  

  # -- Network Settings

  network {
    id     = 0  # <-- ! required since 3.x.x
    bridge = "vmbr0"
    model  = "virtio"
  }

  # -- Disk Settings
  
  scsihw = "virtio-scsi-single"
  
  disks {  # <-- ! changed in 3.x.x
    ide {
      ide0 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          storage = "local-lvm"
          size = "20G"  # <-- Change the desired disk size, ! since 3.x.x size change will trigger a disk resize
          iothread = true  # <-- (Optional) Enable IOThread for better disk performance in virtio-scsi-single
          replicate = false  # <-- (Optional) Enable for disk replication
        }
      }
    }
  }
}
