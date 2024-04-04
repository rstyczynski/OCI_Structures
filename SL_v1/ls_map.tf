
variable "sl_map" {
  type = map(
      object(
        {
          rules = list(object(
            {
              protocol    = string
              source      = optional(string)
              destination = optional(string)
              description = optional(string)
              stateless   = optional(bool)
            })
          )
        }
      )
    )
  
  default = {
      "demo1" = {
      rules = [
        {
          protocol    = "tcp/22",
          destination = "0.0.0.0/0",
          description = "ssh for all!"
        },
        {
          protocol    = "tcp/80-90",
          destination = "0.0.0.0/0"
          stateless   = true,
        },
        {
          protocol    = "tcp/:1521-1523",
          destination = "0.0.0.0/0"
        },
        {
          protocol    = "TcP/22:",
          source = "0.0.0.0/0"
        },
        {
          protocol    = "TcP/21-22:1521-1523",
          source = "0.0.0.0/0"
        }
      ]
      },
      "demo2" = {
        rules = [
          {
            protocol    = "icmp/3.4",
            destination = "0.0.0.0/0"
          },
          {
            protocol = "icmp/8",
            source   = "0.0.0.0/0"
          }
        ]
      }
    }
}

variable "ptc2code" {
  type = map(string)
  default = {
    "TCP" = 6
    "UDP" = 17
    "ICMP" = 1
  }
}

locals {
  sl_map = var.sl_map
  //sl_map = local.sl_lex
}

variable sl_key {
  type = string
  default = "demo1"
}

# destination pattern to auto set destination type
locals {
  regexp_cidr = "([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})\\/([0-9]+)"
}

# add index variable to keep order of records
# it's needed as processing is implemented for subsets of the list
# having index field, it's possible to keep original order in final list
locals {
  sl_indexed = {
    for key, value in local.sl_map : 
    key => {
      rules = [
        for ndx, rule in value.rules :
        {
          _position   = ndx
          protocol    = can(rule.protocol) ? rule.protocol : null
          source      = can(rule.source) ? rule.source : null
          destination = can(rule.destination) ? rule.destination : null
          description = can(rule.description) ? rule.description : null
          stateless   = can(rule.stateless) ? rule.stateless : null
        }
      ]
    }
  }
}
// output "sl_indexed" {
//   value = local.sl_indexed
// }

// # part of the input list is processed for generic patterns
// # /22:
// # /22-23:
// # /22-23:80
// # /22-23:80-81
locals {
  regexp_full = "(?i)(tcp|udp)\\/([0-9]*)-?([0-9]*):([0-9]*)-?([0-9]*)$"

  sl_src_dst = {
    for key, value in local.sl_indexed :
      key => {
        rules = [for rule in value.rules :
          {
            _position = tonumber(rule._position)

            source_string = rule.protocol
            src_port_min  = regex(local.regexp_full, rule.protocol)[1]
            src_port_max  = regex(local.regexp_full, rule.protocol)[2] != "" ? regex(local.regexp_full, rule.protocol)[2] : regex(local.regexp_full, rule.protocol)[1]

            dst_port_min = regex(local.regexp_full, rule.protocol)[3]
            dst_port_max = regex(local.regexp_full, rule.protocol)[4] != "" ? regex(local.regexp_full, rule.protocol)[4] : regex(local.regexp_full, rule.protocol)[3]

            icmp_type = null
            icmp_code = null

            protocol = lower(split("/", rule.protocol)[0])

            source      = rule.source
            source_type = rule.source == null ? null : can(regex(local.regexp_cidr, rule.source)[4]) ? "CIDR_BLOCK" : "SERVICE_CIDR_BLOCK"

            destination      = rule.destination
            destination_type = rule.destination == null ? null : can(regex(local.regexp_cidr, rule.destination)[4]) ? "CIDR_BLOCK" : "SERVICE_CIDR_BLOCK"

            stateless   = rule.stateless
            description = rule.description

            type = "sl_src_dst"
          } if can(regex(local.regexp_full, rule.protocol))
        ]
      }
    }
}
// output "sl_src_dst" {
//   value = local.sl_src_dst
// }

// # another part of the input list is processed for default patterns
// # /80
// # /80-81
locals {
  regexp_dst = "(?i)(tcp|udp)\\/([0-9]*)-?([0-9]*)$"

  sl_dst_only = {
    for key, value in local.sl_indexed : 
      key => { 
      rules = [for rule in value.rules :
        {
          _position = tonumber(rule._position)

          source_string = rule.protocol
          src_port_min  = null
          src_port_max  = null

          dst_port_min = regex(local.regexp_dst, rule.protocol)[1]
          dst_port_max = regex(local.regexp_dst, rule.protocol)[2] != "" ? regex(local.regexp_dst, rule.protocol)[2] : regex(local.regexp_dst, rule.protocol)[1]

          icmp_type = null
          icmp_code = null

          protocol = lower(split("/", rule.protocol)[0])

          source      = rule.source
          source_type = rule.source == null ? null : can(regex(local.regexp_cidr, rule.source)[4]) ? "CIDR_BLOCK" : "SERVICE_CIDR_BLOCK"

          destination      = rule.destination
          destination_type = rule.destination == null ? null : can(regex(local.regexp_cidr, rule.destination)[4]) ? "CIDR_BLOCK" : "SERVICE_CIDR_BLOCK"

          stateless   = rule.stateless
          description = rule.description

          type = "sl_dst_only"
        } if can(regex(local.regexp_dst, rule.protocol))
      ]
    }
  }
}
// output "sl_dst_only" {
//   value = local.sl_dst_only
// }

# process icmp
# icmp/8
# icmp/8.1
locals {
  regexp_icmp = "(?i)(icmp)\\/([0-9]+).?([0-9]*)$"

  sl_icmp = {
    for key, value in local.sl_indexed : 
      key => {
      rules = [for rule in value.rules :
        {
          _position = tonumber(rule._position)

          source_string = rule.protocol

          src_port_min = null
          src_port_max = null

          dst_port_min = null
          dst_port_max = null

          icmp_type = regex(local.regexp_icmp, rule.protocol)[1]
          icmp_code = regex(local.regexp_icmp, rule.protocol)[2] != "" ? regex(local.regexp_icmp, rule.protocol)[2] : null

          protocol = lower(split("/", rule.protocol)[0])

          source      = rule.source
          source_type = rule.source == null ? null : can(regex(local.regexp_cidr, rule.source)[4]) ? "CIDR_BLOCK" : "SERVICE_CIDR_BLOCK"

          destination      = rule.destination
          destination_type = rule.destination == null ? null : can(regex(local.regexp_cidr, rule.destination)[4]) ? "CIDR_BLOCK" : "SERVICE_CIDR_BLOCK"

          stateless   = rule.stateless
          description = rule.description

          type          = "sl_icmp"
        } if can(regex(local.regexp_icmp, rule.protocol))
      ]
    }
  }
}
// output "sl_icmp" {
//   value = local.sl_icmp
// }

# TODO 1. Implement error handling
# process error
locals {
  sl_error = {
    for key, value in local.sl_indexed : 
      key => {
      rules = [for rule in value.rules :
        {
          _position = tonumber(rule._position)
          source_string = rule.protocol

          src_port_min = 0
          src_port_max = null

          dst_port_min = 0
          dst_port_max = null

          icmp_type = null
          icmp_code = null
          
          protocol = "ERROR"

          source      = null
          source_type = null
          
          destination      = null
          destination_type = null

          stateless   = null
          description = null

          type         = "sl_error"
        //} if ! startswith(lower(rule.protocol), "tcp") && ! startswith(lower(rule.protocol), "udp") && ! startswith(lower(rule.protocol), "icmp")
        } if ! can(regex(local.regexp_full, rule.protocol)) && ! can(regex(local.regexp_dst, rule.protocol)) && ! can(regex(local.regexp_icmp, rule.protocol))
      ]
    }
  }
}
output "sl_error" {
  value = local.sl_error
}

# combine both partially processed list to the result
# keep original order
locals {
  sl_processed = {
    for key, value in local.sl_indexed : 
      key => {
      rules = flatten(concat(
          local.sl_src_dst[key].rules,
          local.sl_dst_only[key].rules,
          local.sl_icmp[key].rules,
          local.sl_error[key].rules
        ))
      }
    }
}
// output "sl_processed" {
//   value = local.sl_processed
// }

locals {
  // generate sorted positions for each key
  positions_per_key = {
    for key, value in local.sl_processed : 
      key =>
      sort(formatlist("%010d", [for rule in value.rules : rule._position]))
  }
}
// output "positions_per_key" {
//   value = local.positions_per_key
// }

locals {
  sl = {
    for key, entry in local.sl_processed :
      key => {
      rules = [
        for position in local.positions_per_key[key] : {
          _position = tonumber(position)
          _type = entry.rules[tonumber(position)].type
          _source = entry.rules[tonumber(position)].source_string

          description = entry.rules[tonumber(position)].description

          protocol    = upper(entry.rules[tonumber(position)].protocol)
          stateless   = entry.rules[tonumber(position)].stateless

          source       = entry.rules[tonumber(position)].source
          source_type  = entry.rules[tonumber(position)].source_type

          destination = entry.rules[tonumber(position)].destination
          destination_type = entry.rules[tonumber(position)].destination_type
        
          src_port_min = try(tonumber(entry.rules[tonumber(position)].src_port_min), null)
          src_port_max = entry.rules[tonumber(position)].src_port_max != "" ? try(tonumber(entry.rules[tonumber(position)].src_port_max),null) : try(tonumber(entry.rules[tonumber(position)].src_port_min),null)

          dst_port_min = try(tonumber(entry.rules[tonumber(position)].dst_port_min), null)
          dst_port_max = entry.rules[tonumber(position)].dst_port_max != "" ? try(tonumber(entry.rules[tonumber(position)].dst_port_max),null) : try(tonumber(entry.rules[tonumber(position)].dst_port_min),null)

          icmp_type = try(tonumber(entry.rules[tonumber(position)].icmp_type), null)
          icmp_code = try(tonumber(entry.rules[tonumber(position)].icmp_code), null)
        } 
      ]
    } 
  }
}
output "sl" {
  value = local.sl
}

locals {
  sl_ingress = {
    for key, entry in local.sl_processed :
      key => {
      rules = [
        for position in local.positions_per_key[key] : {
          _position = tonumber(position)
          _type = entry.rules[tonumber(position)].type
          _source = entry.rules[tonumber(position)].source_string

          description = entry.rules[tonumber(position)].description

          protocol    = upper(entry.rules[tonumber(position)].protocol)
          stateless   = entry.rules[tonumber(position)].stateless

          src       = entry.rules[tonumber(position)].source
          src_type  = entry.rules[tonumber(position)].source_type

          destination = entry.rules[tonumber(position)].destination
          destination_type = entry.rules[tonumber(position)].destination_type
        
          src_port_min = try(tonumber(entry.rules[tonumber(position)].src_port_min), null)
          src_port_max = entry.rules[tonumber(position)].src_port_max != "" ? try(tonumber(entry.rules[tonumber(position)].src_port_max),null) : try(tonumber(entry.rules[tonumber(position)].src_port_min),null)

          dst_port_min = try(tonumber(entry.rules[tonumber(position)].dst_port_min), null)
          dst_port_max = entry.rules[tonumber(position)].dst_port_max != "" ? try(tonumber(entry.rules[tonumber(position)].dst_port_max),null) : try(tonumber(entry.rules[tonumber(position)].dst_port_min),null)

          icmp_type = try(tonumber(entry.rules[tonumber(position)].icmp_type), null)
          icmp_code = try(tonumber(entry.rules[tonumber(position)].icmp_code), null)
        } if entry.rules[tonumber(position)].source != null
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
          _source = entry.rules[tonumber(position)].source_string

          description = entry.rules[tonumber(position)].description

          protocol    = upper(entry.rules[tonumber(position)].protocol)
          stateless   = entry.rules[tonumber(position)].stateless

          dst = entry.rules[tonumber(position)].destination
          dst_type = entry.rules[tonumber(position)].destination_type
        
          src_port_min = try(tonumber(entry.rules[tonumber(position)].src_port_min), null)
          src_port_max = entry.rules[tonumber(position)].src_port_max != "" ? try(tonumber(entry.rules[tonumber(position)].src_port_max),null) : try(tonumber(entry.rules[tonumber(position)].src_port_min),null)

          dst_port_min = try(tonumber(entry.rules[tonumber(position)].dst_port_min), null)
          dst_port_max = entry.rules[tonumber(position)].dst_port_max != "" ? try(tonumber(entry.rules[tonumber(position)].dst_port_max),null) : try(tonumber(entry.rules[tonumber(position)].dst_port_min),null)

          icmp_type = try(tonumber(entry.rules[tonumber(position)].icmp_type), null)
          icmp_code = try(tonumber(entry.rules[tonumber(position)].icmp_code), null)
        } if entry.rules[tonumber(position)].destination != null
      ]
    } 
  }
}
// output "sl_egress" {
//   value = local.sl_egress
// }

provider "null" {
  version = "~> 3.0"
}
