variable "endpoint" {
  description = "Proxmox API URL"
  type        = string
}

variable "api_token" {
  description = "Proxmox API Token ID"
  type        = string
}

variable "target_node" {
  description = "the Node inside the terraform machine no the actual VM"
  type        = string
}

variable "node_name" {
  description = "Name of the virtual machine"
  type        = string
}
variable "secret" {
  description = "Name of the virtual machine"
  type        = string
}
