#
# Interface to CIZ Network module
#

// get rules for egress
output "sl_egress_key" {
  value = local.sl_egress[var.sl_key].rules
}

// get rules for ingress
output "sl_ingress_key" {
  value = local.sl_ingress[var.sl_key].rules
}
