variable "tailscale_auth_key" {
  description = "Single-use Tailscale auth key for bootstrap access. Removed once NetBird is live."
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "Azure VM size for the NetBird server"
  type        = string
  default     = "Standard_B2als_v2" # 2vCPU, 4GB RAM
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key for the VM admin user"
  type        = string
  default     = "~/.ssh/ztlab_netbird.pub"
}
