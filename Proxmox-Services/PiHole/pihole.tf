# TODO (The whole thing)
terraform {
  required_version = ">= 0.13.0"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.endpoint
  pm_api_token_id     = var.api_token
  pm_api_token_secret = var.secret
  pm_tls_insecure     = true
}

resource "proxmox_vm_qemu" "your-vm" {
  name        = "Pihole"
  agent       = 1  
  target_node = "pve"
  tags        = "test"

  # Static IP
  os_type   = "cloud-init"
  ipconfig0 = "ip=10.0.0.5/24,gw=10.0.0.1"

  # Template cloning
  clone      = "ubuntu-22.04"
  full_clone = true

  # Boot Settings
  onboot  = true
  startup = ""

  # Hardware
  bios          = "seabios"
  cores         = 2
  sockets       = 1
  cpu_type      = "host"
  memory  = 2048
  balloon = 2048

  # Network
  network {
    id     = 0
    bridge = "vmbr0"
    model  = "virtio"
  }
}

resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory.ini pihole.yml"
  }
  depends_on = [proxmox_vm_qemu.your-vm]
}
