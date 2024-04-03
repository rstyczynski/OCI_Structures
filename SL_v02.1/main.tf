provider "null" {
  version = "~> 3.0"
}

variable "security_list" {
  type = list(
    object(
      {
        key = string
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
  default = [
    {
      key = "demo1",
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
          destination = "0.0.0.0/0"
        },
        {
          protocol    = "TcP/21-22:1521-1523",
          destination = "0.0.0.0/0"
        }
      ]
    },
    {
      key = "demo2",
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
  ]
}

# destination pattern to auto set destination type
locals {
  regexp_cidr = "([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})\\/([0-9]+)"
}

# add index variable to keep order of records
# it's needed as processing is implemented for subsets of the list
# having index field, it's possible to keep original order in final list
locals {
  sl_indexed = [
    for entry in var.security_list : {
      key = entry.key
      rules = [for idx, rule in entry.rules : {
        position    = idx
        protocol    = rule.protocol
        source      = rule.source
        destination = rule.destination
        stateless   = rule.stateless
        description = rule.description
      }]
    }
  ]
}

// # part of the input list is processed for generic patterns
// # /22:
// # /22-23:
// # /22-23:80
// # /22-23:80-81
locals {
  full_protocol = "(?i)(tcp|udp)\\/([0-9]*)-?([0-9]*):([0-9]*)-?([0-9]*)$"

  sl_src_dst = [
    for entry in local.sl_indexed : {
      key = entry.key
      rules = [for rule in entry.rules :
        {
          position = tonumber(rule.position)

          source_string = rule.protocol
          src_port_min  = regex(local.full_protocol, rule.protocol)[1]
          src_port_max  = regex(local.full_protocol, rule.protocol)[2] != "" ? regex(local.full_protocol, rule.protocol)[2] : regex(local.full_protocol, rule.protocol)[1]

          dst_port_min = regex(local.full_protocol, rule.protocol)[3]
          dst_port_max = regex(local.full_protocol, rule.protocol)[4] != "" ? regex(local.full_protocol, rule.protocol)[4] : regex(local.full_protocol, rule.protocol)[3]

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
        } if can(regex(local.full_protocol, rule.protocol))
      ]
    }
  ]
}

// # another part of the input list is processed for default patterns
// # /80
// # /80-81
locals {
  dst_protocol = "(?i)(tcp|udp)\\/([0-9]*)-?([0-9]*)$"

  sl_dst_only = [
    for entry in local.sl_indexed : {
      key = entry.key
      rules = [for rule in entry.rules :
        {
          position = tonumber(rule.position)

          source_string = rule.protocol
          src_port_min  = null
          src_port_max  = null

          dst_port_min = regex(local.dst_protocol, rule.protocol)[1]
          dst_port_max = regex(local.dst_protocol, rule.protocol)[2] != "" ? regex(local.dst_protocol, rule.protocol)[2] : regex(local.dst_protocol, rule.protocol)[1]

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
        } if can(regex(local.dst_protocol, rule.protocol))
      ]
    }
  ]
}

# process icmp
# icmp/8
# icmp/8.1
locals {
  icmp_msg = "(?i)(icmp)\\/([0-9]+).?([0-9]*)$"

  sl_icmp = [
    for entry in local.sl_indexed : {
      key = entry.key
      rules = [for rule in entry.rules :
        {
          position = tonumber(rule.position)

          source_string = rule.protocol

          src_port_min = null
          src_port_max = null

          dst_port_min = null
          dst_port_max = null

          icmp_type = regex(local.icmp_msg, rule.protocol)[1]
          icmp_code = regex(local.icmp_msg, rule.protocol)[2] != "" ? regex(local.icmp_msg, rule.protocol)[2] : null

          protocol = lower(split("/", rule.protocol)[0])

          source      = rule.source
          source_type = rule.source == null ? null : can(regex(local.regexp_cidr, rule.source)[4]) ? "CIDR_BLOCK" : "SERVICE_CIDR_BLOCK"

          destination      = rule.destination
          destination_type = rule.destination == null ? null : can(regex(local.regexp_cidr, rule.destination)[4]) ? "CIDR_BLOCK" : "SERVICE_CIDR_BLOCK"

          stateless   = rule.stateless
          description = rule.description

          type          = "sl_icmp"
        } if can(regex(local.icmp_msg, rule.protocol))
      ]
    }
  ]
}

# combine both partially processed list to the result
# keep oryginal order
locals {
  sl_processed = [
    for entry in local.sl_indexed : {
      key = entry.key
      rules = flatten(concat(
        [for sl in local.sl_src_dst : sl.rules if sl.key == entry.key],
        [for sl in local.sl_dst_only : sl.rules if sl.key == entry.key],
        [for sl in local.sl_icmp : sl.rules if sl.key == entry.key]
      ))
    }
  ]

  // generate sorted positions for each key
  positions_per_key = {
    for entry in local.sl_processed : entry.key =>
    sort(formatlist("%010d", [for rule in entry.rules : rule.position]))
  }

  security_list = [
    for entry in local.sl_processed : {
      key = entry.key
      rules = [
        for position in local.positions_per_key[entry.key] : {
          _position = tonumber(position)
          _type = entry.rules[tonumber(position)].type
          _source = entry.rules[tonumber(position)].source_string

          protocol = upper(entry.rules[tonumber(position)].protocol)
          stateless   = entry.rules[tonumber(position)].stateless

          source       = entry.rules[tonumber(position)].source
          source_type  = entry.rules[tonumber(position)].source_type
          src_port_min = try(tonumber(entry.rules[tonumber(position)].src_port_min), null)
          src_port_max = entry.rules[tonumber(position)].src_port_max != "" ? try(tonumber(entry.rules[tonumber(position)].src_port_max),null) : try(tonumber(entry.rules[tonumber(position)].src_port_min),null)

          destination = entry.rules[tonumber(position)].destination
          destination_type = entry.rules[tonumber(position)].destination_type
          dst_port_min = try(tonumber(entry.rules[tonumber(position)].dst_port_min), null)
          dst_port_max = entry.rules[tonumber(position)].dst_port_max != "" ? try(tonumber(entry.rules[tonumber(position)].dst_port_max),null) : try(tonumber(entry.rules[tonumber(position)].dst_port_min),null)

          icmp_type = try(tonumber(entry.rules[tonumber(position)].icmp_type), null)
          icmp_code = try(tonumber(entry.rules[tonumber(position)].icmp_code), null)

          description = entry.rules[tonumber(position)].description
        }
      ]
    }
  ]
}

output "security_list" {
  value = local.security_list
}

// output "security_list_ingerss" {
//   value = [for sl in local.security_list : sl if sl.key == "demo1" && sl.source != null]
// }

// output "security_list_egress" {
//   value = [for sl in local.security_list : sl if sl.key == "demo1" && sl.destination != null]
// }

