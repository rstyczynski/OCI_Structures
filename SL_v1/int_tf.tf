
#
# keep result in terraform provider data structure
# https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list
# 
locals {
  sl_tf = {
    for key, entry in local.sl_processed :
      key => {
      rules = [
        for position in local.positions_per_key[key] : {
          _position = tonumber(position)
          _type = entry.rules[tonumber(position)].type
          _source = entry.rules[tonumber(position)].src_string

          description = entry.rules[tonumber(position)].description

          protocol    = local.protocol2code[upper(entry.rules[tonumber(position)].protocol)]
          stateless   = entry.rules[tonumber(position)].stateless

          source       = entry.rules[tonumber(position)].src
          source_type  = entry.rules[tonumber(position)].src_type

          destination = entry.rules[tonumber(position)].dst
          destination_type = entry.rules[tonumber(position)].dst_type
        
          tcp_options = upper(entry.rules[tonumber(position)].protocol) == "TCP" ? {
            min = try(tonumber(entry.rules[tonumber(position)].dst_port_min), null)
            max = entry.rules[tonumber(position)].dst_port_max != "" ? try(tonumber(entry.rules[tonumber(position)].dst_port_max),null) : try(tonumber(entry.rules[tonumber(position)].dst_port_min),null)
            source_port_range = {
              min = try(tonumber(entry.rules[tonumber(position)].src_port_min), null)
              max = entry.rules[tonumber(position)].src_port_max != "" ? try(tonumber(entry.rules[tonumber(position)].src_port_max),null) : try(tonumber(entry.rules[tonumber(position)].src_port_min),null)
            }
          } : null

          udp_options = upper(entry.rules[tonumber(position)].protocol) == "UDP" ? {
            min = try(tonumber(entry.rules[tonumber(position)].dst_port_min), null)
            max = entry.rules[tonumber(position)].dst_port_max != "" ? try(tonumber(entry.rules[tonumber(position)].dst_port_max),null) : try(tonumber(entry.rules[tonumber(position)].dst_port_min),null)
            source_port_range = {
              min = try(tonumber(entry.rules[tonumber(position)].src_port_min), null)
              max = entry.rules[tonumber(position)].src_port_max != "" ? try(tonumber(entry.rules[tonumber(position)].src_port_max),null) : try(tonumber(entry.rules[tonumber(position)].src_port_min),null)
            }
          } : null

          icmp_options = upper(entry.rules[tonumber(position)].protocol) == "ICMP" ? {
            type = try(tonumber(entry.rules[tonumber(position)].icmp_type), null)
            code = try(tonumber(entry.rules[tonumber(position)].icmp_code), null)
          } : null
        } 
      ]
    } 
  }
}
output "sl_tf" {
  value = local.sl_tf
}


locals {
  sl_tf_ingress = {
    for key, entry in local.sl_tf :
      key => {
        rules = [ for rule in entry.rules : rule if rule.source != null ]
      }
  }
}
// output "sl_tf_ingress" {
//   value = local.sl_tf_ingress
// }

locals {
  sl_tf_egress = {
     for key, entry in local.sl_tf :
      key => {
        rules = [ for rule in entry.rules : rule if rule.destination != null ]
      }
  }
}
// output "sl_tf_egress" {
//   value = local.sl_tf_egress
// }

// get rules for egress
output "sl_tf_egress_key" {
  value = local.sl_tf_egress[var.sl_key].rules
}

// get rules for ingress
output "sl_tf_ingress_key" {
  value = local.sl_tf_ingress[var.sl_key].rules
}
