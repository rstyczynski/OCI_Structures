
provider "null" {
  version = "~> 3.0"
}

variable "input_string" {
  type    = string
  default = "tcp/12-14:22-24"
}

locals {
  segments       = split("/", lower(var.input_string))
  protocol       = element(local.segments, 0)
  src_dst_string = element(local.segments, 1)

  src_dst_segments = split(":", local.src_dst_string)

  # tcp:/:22  - length(local.src_dst_segments) > 1
  # tcp:/10:22  - length(local.src_dst_segments) > 1  
  src_range = length(local.src_dst_segments) > 1 ? split("-", element(local.src_dst_segments, 0)) : [""]

  # tcp/:22   - element(local.src_dst_segments, 0) == "" ? null
  # tcp/10:22 - length(local.src_dst_segments) > 1 
  src_min_proposal = element(local.src_range, 0) == "" ? null : length(local.src_dst_segments) > 1 ? element(local.src_range, 0) == "" ? null : tonumber(element(local.src_range, 0)) : null
  src_max          = element(local.src_range, 1) == "" ? local.src_min_proposal : length(local.src_dst_segments) > 1 ? element(local.src_range, 1) == "" ? null : tonumber(element(local.src_range, 1)) : local.src_min_proposal
  # tcp/-12   - to handle this dst_min_proposal is introduced
  # tcp/-     - sets min/max to null
  src_min = local.src_min_proposal == null ? local.src_max : local.src_min_proposal

  dst_range        = split("-", element(local.src_dst_segments, 1))
  dst_min_proposal = element(local.dst_range, 0) == "" ? null : tonumber(element(local.dst_range, 0))
  dst_max          = element(local.dst_range, 1) == "" ? local.dst_min_proposal : tonumber(element(local.dst_range, 1))
  dst_min          = local.dst_min_proposal == null ? local.dst_max : local.dst_min_proposal
}

output "protocol" {
  value = local.protocol
}

output "src_min" {
  value = local.src_min
}

output "src_max" {
  value = local.src_max
}

output "dst_min" {
  value = local.dst_min
}

output "dst_max" {
  value = local.dst_max
}
