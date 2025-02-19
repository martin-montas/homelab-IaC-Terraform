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

resource "proxmox_lxc" "pihole_container" {
  hostname     = "Pihole-CT-test"
  target_node  = "pve"
  vmid         = 105
  tags         = "test"
  unprivileged = true
  start        = true
  cores        = 2
  memory       = 1024
  password     = var.password
  swap         = 512
  ostemplate   = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"

  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "10.0.0.5/24"
    gw     =  "10.0.0.1"
  }
}

