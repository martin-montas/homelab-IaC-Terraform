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

resource "proxmox_lxc" "your-vm" {
    hostname        = "Pihole-CT-test"
    target_node     = "pve" 
    vmid            = 104
    tags            = "test"
    unprivileged    = true
    start           = true
    cores           = 2
    memory          = 1024
    password        = var.password
    swap            = 512
    ostemplate      = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
    rootfs {
        storage     = "local-lvm" # Change to your Proxmox storage
        size        = "8G"
    }
    network {
        name        = "eth0"
        bridge      = "vmbr0"
        ip          = "dhcp" # Or use "192.168.1.100/24" for a static IP
    }
    mountpoint {
    slot            = 0             # Required slot index (mp0, mp1, etc.)
    key             = "mp0"
    storage         = "local-lvm"       # Adjust this to your Proxmox storage
    mp              = "/mnt/shared" # Path inside the container
    size            = "10G"
  }
}
