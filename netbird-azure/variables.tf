variable "tailscale_auth_key" {
  description = "Single-use Tailscale auth key for bootstrap access. Removed once NetBird is live."
  type        = string
  sensitive   = true
}
