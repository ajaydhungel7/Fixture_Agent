locals {
  agentcore_network_mode_effective = var.agentcore_use_vpc ? "VPC" : var.agentcore_network_mode
}
