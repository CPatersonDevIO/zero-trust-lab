locals {
  location = "uksouth"
  project  = "ztlab"
  workload = "netbird"
  region   = "uks"

  # Builds "ztlab-netbird-uks" once, so every name below uses it
  name_suffix = "${local.project}-${local.workload}-${local.region}"

  tags = {
    project    = "zero-trust-lab"
    component  = "netbird"
    managed_by = "terraform"
  }
}
