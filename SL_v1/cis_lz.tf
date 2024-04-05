#
# Interface to CIZ Network module
#


locals {
  sl_ingress = {
    for key, entry in local.sl_processed :
      key => {
      rules = [
        for position in local.positions_per_key[key] : {
          _position = tonumber(position)
          _type = entry.rules[tonumber(position)].type
          _source = entry.rules[tonumber(position)].src_string

          description = entry.rules[tonumber(position)].description

          protocol    = upper(entry.rules[tonumber(position)].protocol)
          stateless   = entry.rules[tonumber(position)].stateless

          src       = entry.rules[tonumber(position)].src
          src_type  = entry.rules[tonumber(position)].src_type

          dst = entry.rules[tonumber(position)].dst
          dst_type = entry.rules[tonumber(position)].dst_type
        
          src_port_min = try(tonumber(entry.rules[tonumber(position)].src_port_min), null)
          src_port_max = entry.rules[tonumber(position)].src_port_max != "" ? try(tonumber(entry.rules[tonumber(position)].src_port_max),null) : try(tonumber(entry.rules[tonumber(position)].src_port_min),null)

          dst_port_min = try(tonumber(entry.rules[tonumber(position)].dst_port_min), null)
          dst_port_max = entry.rules[tonumber(position)].dst_port_max != "" ? try(tonumber(entry.rules[tonumber(position)].dst_port_max),null) : try(tonumber(entry.rules[tonumber(position)].dst_port_min),null)

          icmp_type = try(tonumber(entry.rules[tonumber(position)].icmp_type), null)
          icmp_code = try(tonumber(entry.rules[tonumber(position)].icmp_code), null)
        } if entry.rules[tonumber(position)].src != null
      ]
    } 
  }
}
// output "sl_ingress" {
//   value = local.sl_ingress
// }

locals {
  sl_egress = {
    for key, entry in local.sl_processed :
      key => {
      rules = [
        for position in local.positions_per_key[key] : {
          _position = tonumber(position)
          _type = entry.rules[tonumber(position)].type
          _source = entry.rules[tonumber(position)].src_string

          description = entry.rules[tonumber(position)].description

          protocol    = upper(entry.rules[tonumber(position)].protocol)
          stateless   = entry.rules[tonumber(position)].stateless

          dst = entry.rules[tonumber(position)].dst
          dst_type = entry.rules[tonumber(position)].dst_type
        
          src_port_min = try(tonumber(entry.rules[tonumber(position)].src_port_min), null)
          src_port_max = entry.rules[tonumber(position)].src_port_max != "" ? try(tonumber(entry.rules[tonumber(position)].src_port_max),null) : try(tonumber(entry.rules[tonumber(position)].src_port_min),null)

          dst_port_min = try(tonumber(entry.rules[tonumber(position)].dst_port_min), null)
          dst_port_max = entry.rules[tonumber(position)].dst_port_max != "" ? try(tonumber(entry.rules[tonumber(position)].dst_port_max),null) : try(tonumber(entry.rules[tonumber(position)].dst_port_min),null)

          icmp_type = try(tonumber(entry.rules[tonumber(position)].icmp_type), null)
          icmp_code = try(tonumber(entry.rules[tonumber(position)].icmp_code), null)
        } if entry.rules[tonumber(position)].dst != null
      ]
    } 
  }
}
// output "sl_egress" {
//   value = local.sl_egress
// }

// get rules for egress
// output "sl_egress_key" {
//   value = local.sl_egress[var.sl_key].rules
// }

// get rules for ingress
// output "sl_ingress_key" {
//   value = local.sl_ingress[var.sl_key].rules
// }
