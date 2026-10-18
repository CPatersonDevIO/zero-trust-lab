output "public_ip" {
  description = "Public IP of the NetBird VM, for the Cloudflare DNS record"
  value       = azurerm_public_ip.netbird.ip_address
}
