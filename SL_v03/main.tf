# 3. CIDR may be rendered from label

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
          destination = "internet",
          description = "ssh for all!"
        },
        {
          protocol    = "tcp/80-90",
          destination = "bad"
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

locals {
  regexp_cidr = "([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})\\/([0-9]+)"
}

locals {
    cidrs = {
        internet = "0.0.0.0/0"
    }
}

locals {
  sl_cidr = {
    for key, value in var.sl_map : 
    key => {
      rules = [
        for ndx, rule in value.rules :
        {
          protocol    = can(rule.protocol) ? rule.protocol : null
          src         = rule.src == null ? null : can(regex(local.regexp_cidr, rule.src)) ? rule.src : can(local.cidrs[rule.src]) ? local.cidrs[rule.src] : "label not in local.cidrs"
          dst         = rule.dst == null ? null : can(regex(local.regexp_cidr, rule.dst)) ? rule.dst : can(local.cidrs[rule.dst]) ? local.cidrs[rule.dst] : "label not in local.cidrs"
          description = can(rule.description) ? rule.description : null
          stateless   = can(rule.stateless) ? rule.stateless : null
        }
      ]
    }
  }
}
output "sl_cidr" {
  value = local.sl_cidr
}



provider "null" {
  version = "~> 3.0"
}

