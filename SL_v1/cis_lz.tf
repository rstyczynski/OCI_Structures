#
# Interface to CIZ Network module
#

locals {
  sl_cislz_ingress = {
    for key, entry in local.sl_cislz :
      key => {
        rules = [ for rule in entry.rules : rule if rule.src != null ]
      }
  }
}
// output "sl_cislz_ingress" {
//   value = local.sl_cislz_ingress
// }

locals {
  sl_cislz_egress = {
     for key, entry in local.sl_cislz :
      key => {
        rules = [ for rule in entry.rules : rule if rule.dst != null ]
      }
  }
}
// output "sl_cislz_egress" {
//   value = local.sl_cislz_egress
// }

// get rules for egress
output "sl_cislz_egress_key" {
  value = local.sl_cislz_egress[var.sl_cislz_key].rules
}

// get rules for ingress
output "sl_cislz_ingress_key" {
  value = local.sl_cislz_ingress[var.sl_cislz_key].rules
}
