#
# Interface to CIZ Network module
#

// get rules for egress
output "sl_egress_key" {
  value = [for records in local.sl_egress[var.sl_key].rules : records]
}

// get rules for ingress
output "sl_ingress_key" {
  value = [for records in local.sl_ingress[var.sl_key].rules : records ]
}
