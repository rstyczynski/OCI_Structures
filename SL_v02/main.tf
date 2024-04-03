provider "null" {
  version = "~> 3.0"
}

variable "security_list" {
  type = list(
  object({
      key = string
      protocol    = string
      source      = optional(string)
      destination = optional(string)
      description = optional(string)
      stateless   = optional(bool)
    })
  )
  default = [
    {
      key = "demo1",
      protocol    = "tcp/22",
      destination = "0.0.0.0/0",
      description = "ssh for all!"
    },
    {
      key = "demo1",
      protocol    = "tcp/80-90",
      destination = "0.0.0.0/0"
      stateless   = true,
      }, 
    {
      key = "demo1",
      protocol    = "tcp/:1521-1523",
      destination = "0.0.0.0/0"
    },
    {
      key = "demo1",
      protocol    = "TcP/22:",
      destination = "0.0.0.0/0"
    },
    {
      key = "demo1",
      protocol    = "TcP/21-22:1521-1523",
      destination = "0.0.0.0/0"
    },
    {
      key = "demo1",
      protocol    = "icmp/3.4",
      destination = "0.0.0.0/0"
    },
    {
      key = "demo1",
      protocol    = "icmp/8",
      source = "0.0.0.0/0"
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
    for idx, value in var.security_list :
    {
      key = value.key
      position    = idx
      protocol    = value.protocol
      source      = value.source
      destination = value.destination
      stateless   = value.stateless
      description = value.description
    }
  ]
}

# part of the input list is processed for generic patterns
# /22:
# /22-23:
# /22-23:80
# /22-23:80-81
locals {
  full_protocol = "(?i)(tcp|udp)\\/([0-9]*)-?([0-9]*):([0-9]*)-?([0-9]*)$"

  sl_src_dst = [
    for value in local.sl_indexed :
    {
      key = value.key
      position = tonumber(value.position)

      source_string = value.protocol
      src_port_min  = regex(local.full_protocol, value.protocol)[1]
      src_port_max  = regex(local.full_protocol, value.protocol)[2] != "" ? regex(local.full_protocol, value.protocol)[2] : regex(local.full_protocol, value.protocol)[1]

      dst_port_min = regex(local.full_protocol, value.protocol)[3]
      dst_port_max = regex(local.full_protocol, value.protocol)[4] != "" ? regex(local.full_protocol, value.protocol)[4] : regex(local.full_protocol, value.protocol)[3]

      icmp_type = null
      icmp_code = null

      protocol = lower(split("/", value.protocol)[0])

      source      = value.source
      source_type = value.source == null ? null : can(regex(local.regexp_cidr, value.source)[4]) ? "CIDR_BLOCK" : "SERVICE_CIDR_BLOCK"

      destination      = value.destination
      destination_type = value.destination == null ? null : can(regex(local.regexp_cidr, value.destination)[4]) ? "CIDR_BLOCK" : "SERVICE_CIDR_BLOCK"

      stateless   = value.stateless
      description = value.description

      type = "sl_src_dst"
    } if can(regex(local.full_protocol, value.protocol))
  ]
}

# another part of the input list is processed for default patterns
# /80
# /80-81
locals {
  dst_protocol = "(?i)(tcp|udp)\\/([0-9]*)-?([0-9]*)$"

  sl_dst_only = [
    for value in local.sl_indexed :
    {
      key = value.key
      position = tonumber(value.position)

      source_string = value.protocol
      src_port_min  = null
      src_port_max  = null

      dst_port_min = regex(local.dst_protocol, value.protocol)[1]
      dst_port_max = regex(local.dst_protocol, value.protocol)[2] != "" ? regex(local.dst_protocol, value.protocol)[2] : regex(local.dst_protocol, value.protocol)[1]

      icmp_type = null
      icmp_code = null

      protocol = lower(split("/", value.protocol)[0])

      source      = value.source
      source_type = value.source == null ? null : can(regex(local.regexp_cidr, value.source)[4]) ? "CIDR_BLOCK" : "SERVICE_CIDR_BLOCK"

      destination      = value.destination
      destination_type = value.destination == null ? null : can(regex(local.regexp_cidr, value.destination)[4]) ? "CIDR_BLOCK" : "SERVICE_CIDR_BLOCK"

      stateless   = value.stateless
      description = value.description

      type = "sl_dst_only"
    } if can(regex(local.dst_protocol, value.protocol))
  ]
}

locals {
  icmp_msg = "(?i)(icmp)\\/([0-9]+).?([0-9]*)$"

  sl_icmp = [
    for value in local.sl_indexed :
    {
      key = value.key
      position      = tonumber(value.position)

      source_string = value.protocol

      src_port_min = null
      src_port_max = null

      dst_port_min = null
      dst_port_max = null

      icmp_type = regex(local.icmp_msg, value.protocol)[1]
      icmp_code = regex(local.icmp_msg, value.protocol)[2] != "" ? regex(local.icmp_msg, value.protocol)[2] : null

      protocol = lower(split("/", value.protocol)[0])

      source      = value.source
      source_type = value.source == null ? null : can(regex(local.regexp_cidr, value.source)[4]) ? "CIDR_BLOCK" : "SERVICE_CIDR_BLOCK"

      destination      = value.destination
      destination_type = value.destination == null ? null : can(regex(local.regexp_cidr, value.destination)[4]) ? "CIDR_BLOCK" : "SERVICE_CIDR_BLOCK"

      stateless   = value.stateless
      description = value.description

      type = "sl_icmp"
    } if can(regex(local.icmp_msg, value.protocol))
  ]
}

# combine both partially processed list to the result
# keep oryginal order
locals {
  sl_processed = concat(local.sl_src_dst, local.sl_dst_only, local.sl_icmp)

  # numerical sort
  # Source: https://blog.sharebear.co.uk/2022/01/sorting-numerically-in-terraform/
  string_position        = formatlist("%010d", [for record in local.sl_processed : record.position])
  sorted_string_position = sort(local.string_position)
  sorted_position        = [for idx in local.sorted_string_position : tonumber(idx)]
  security_list = [
    for position in local.sorted_position : {

      position     = position

      key = lookup({ for record in local.sl_processed : record.position => record.key }, position, "")

      dst_port_min = lookup({ for record in local.sl_processed : record.position => record.dst_port_min }, position, "") != "" ? tonumber(lookup({ for record in local.sl_processed : record.position => record.dst_port_min }, position, "")) : null
      dst_port_max = lookup({ for record in local.sl_processed : record.position => record.dst_port_max }, position, "") != "" ? tonumber(lookup({ for record in local.sl_processed : record.position => record.dst_port_max }, position, "")) : null

      src_port_min = lookup({ for record in local.sl_processed : record.position => record.src_port_min }, position, "") != "" ? tonumber(lookup({ for record in local.sl_processed : record.position => record.src_port_min }, position, "")) : null
      src_port_max = lookup({ for record in local.sl_processed : record.position => record.src_port_max }, position, "") != "" ? tonumber(lookup({ for record in local.sl_processed : record.position => record.src_port_max }, position, "")) : null

      icmp_type = lookup({ for record in local.sl_processed : record.position => record.icmp_type }, position, "") != "" ? tonumber(lookup({ for record in local.sl_processed : record.position => record.icmp_type }, position, "")) : null
      icmp_code = lookup({ for record in local.sl_processed : record.position => record.icmp_code }, position, "") != "" ? tonumber(lookup({ for record in local.sl_processed : record.position => record.icmp_code }, position, "")) : null

      protocol = upper(lookup({ for record in local.sl_processed : record.position => record.protocol }, position, null))

      source      = lookup({ for record in local.sl_processed : record.position => record.source }, position, null)
      source_type = lookup({ for record in local.sl_processed : record.position => record.source_type }, position, null)

      destination      = lookup({ for record in local.sl_processed : record.position => record.destination }, position, null)
      destination_type = lookup({ for record in local.sl_processed : record.position => record.destination_type }, position, null)

      stateless   = lookup({ for record in local.sl_processed : record.position => record.stateless }, position, null)
      description = lookup({ for record in local.sl_processed : record.position => record.description }, position, null)

      source_string = lookup({ for record in local.sl_processed : record.position => record.source_string }, position, null)
      type          = lookup({ for record in local.sl_processed : record.position => record.type }, position, null)
    }
  ]
}

output "input_security_list" {
  value = var.security_list
}

output "security_list" {
  value = local.security_list
}

output "security_list_ingerss" {
  value = [for sl in local.security_list : sl if sl.key == "demo1" && sl.source != null ]
}

output "security_list_egress" {
  value = [for sl in local.security_list : sl if sl.key == "demo1" && sl.destination != null ]
}