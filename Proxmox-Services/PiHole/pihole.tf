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
    ip     = "dhcp"  # DHCP assigned IP
  }

  mountpoint {
    slot    = 0
    storage = "local-lvm"
    mp      = "/mnt/shared" # Correct path inside the container
    size    = "10G"
  }
}

resource "null_resource" "get_ip_and_run_ansible" {
  depends_on = [proxmox_lxc.pihole_container]

  provisioner "local-exec" {
    command = <<EOT
      sleep 10  # Wait for Proxmox to assign the IP
      CONTAINER_ID=$(curl -s -k --header "Authorization: PVEAPIToken=${var.api_token}" \
        "https://${var.proxmox_host}:8006/api2/json/nodes/${var.target_node}/lxc" | jq -r '.data[] | select(.name=="Pihole-CT-test") | .vmid')

      CONTAINER_IP=$(curl -s -k --header "Authorization: PVEAPIToken=${var.api_token}" \
        "https://${var.proxmox_host}:8006/api2/json/nodes/${var.target_node}/lxc/$CONTAINER_ID/config" | jq -r '.data.ip_address')

      echo "[proxmox]" > inventory.ini
      echo "$CONTAINER_IP ansible_user=root ansible_password=${var.password} ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> inventory.ini

      ansible-playbook -i inventory.ini pihole.yml
    EOT
  }
}
