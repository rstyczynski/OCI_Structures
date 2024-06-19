variable "sl_lang" {
  type = map(list(string))

  default = {
      "demo1" = [
        "permit TcP/21-22:1521-1523 to on_premises /* DB for some of you */",
        "accept uDP/20000-30000:80-90 from all /* HTTP over UDP for some of you */",
        "permit tcp/:1521-1523 stateless to 0.0.0.0/0",
        "accept uDP/22-23 from 0.0.0.0/0 /* strange ingress udp */",
        "permit tcp/22 to 0.0.0.0/0 /* ssh for all! */",
        "accept TcP/21-22:1521-1523 stateless from 0.0.0.0/0 /* DB for everyone */" ,
        "permit tcp/80-90 stateless to 0.0.0.0/0 /* stateless extended http */",
        "permit tcp/22 to 0.0.0.0/0 /* ssh for all! */",
        "accept uDP/222-223 from 0.0.0.0/0",
      ],
      "demo2" = [
        "permit icmp/3.4 to 0.0.0.0/0 /* egress icmp type 3, code 4 */",
        "accept icmp/8 from 0.0.0.0/0", 
        "accept icmp/1. from 0.0.0.0/0 /* icmp type 1 */",
        "permit icmp/3. stateless to 0.0.0.0/0",
        "accept icmp/8.1 from 0.0.0.0/0"        
        ],
      "demo3" = [
        "accept icmp/8 from 0.0.0.0/0", 
        "accept icmp/1. from 0.0.0.0/0 /* icmp type 1 */",
        "accept icmp/8.1 stateless from _test.label_multiple",
        "permit icmp/8 to 0.0.0.0/0", 
        "permit icmp/1. to 0.0.0.0/0 /* icmp type 1 */",
        "permit icmp/8.1 stateless to _test.label_multiple"       
        ]
      }
}
# output sl_lang {
#     value = var.sl_lang
# }

#  pattern to decode lexical rule
locals {
    regexp_lang_egress = "^permit\\s+${local.regexp_ip_ports_full}\\s*${local.regexp_stateless}\\s+to\\s+${local.regexp_label}\\s*${local.regexp_comment_option}"
    regexp_lang_ingress = "^accept\\s+${local.regexp_ip_ports_full}\\s*${local.regexp_stateless}\\s+from\\s+${local.regexp_label}\\s*${local.regexp_comment_option}"
}

# patterns for special case of dst only
locals {
    regexp_lang_egress_dst = "^permit\\s+${local.regexp_ip_ports_dst}\\s*${local.regexp_stateless}\\s+to\\s+${local.regexp_label}\\s*${local.regexp_comment_option}"
    # regexp_lang_ingress_dst_cmt takes full syntax with comments
    # regexp_lang_ingress_dst is ended by $
    # both are workaround for lack of knowledge how to forbid ':' character after ports.
    # w/o above ingress_dst regexp matches generic regexp_lang_ingress
    regexp_lang_ingress_dst_cmt =  "^accept\\s+${local.regexp_ip_ports_dst}\\s*${local.regexp_stateless}\\s+from\\s+${local.regexp_label}\\s+${local.regexp_comment}"
    regexp_lang_ingress_dst = "^accept\\s+${local.regexp_ip_ports_dst}\\s*${local.regexp_stateless}\\s+from\\s+${local.regexp_label}\\s*${local.regexp_eol}"
}
# output regexp_lang_egress_dst {
#   value = local.regexp_lang_egress_dst
# }

# patterns for icmp
locals {
    regexp_lang_icmp_egress = "^permit\\s+${local.regexp_icmp_tc}\\s*${local.regexp_stateless}\\s+to\\s+${local.regexp_label}\\s*${local.regexp_eol}"
    #"^permit\\s+%s\\s+to%s\\s+\\s*%s\\s*%s",local.regexp_icmp_tc, local.regexp_label, local.regexp_stateless, local.regexp_eol)
    regexp_lang_icmp_egress_cmt = "^permit\\s+${local.regexp_icmp_tc}\\s*${local.regexp_stateless}\\s+to\\s+${local.regexp_label}\\s+${local.regexp_comment}"
    #format("^permit\\s+%s\\s+to%s\\s+\\s*%s\\s*%s",local.regexp_icmp_tc, local.regexp_label, local.regexp_stateless, local.regexp_comment)
    regexp_lang_icmp_ingress = "^accept\\s+${local.regexp_icmp_tc}\\s*${local.regexp_stateless}\\s+from\\s+${local.regexp_label}\\s*${local.regexp_eol}"
    #format("^accept\\s+%s\\s+from\\s+%s\\s*%s\\s*%s",local.regexp_icmp_tc, local.regexp_label, local.regexp_stateless, local.regexp_eol)
    regexp_lang_icmp_ingress_cmt =  "^accept\\s+${local.regexp_icmp_tc}\\s*${local.regexp_stateless}\\s+from\\s+${local.regexp_label}\\s+${local.regexp_comment}"
    #format("^accept\\s+%s\\s+from\\s+%s\\s*%s\\s*%s",local.regexp_icmp_tc, local.regexp_label, local.regexp_stateless, local.regexp_comment)
}

# add index variable to keep order of records
# it's needed as processing is implemented for subsets of the list
# having index field, it's possible to keep original order in final list
locals {
  sl_lang_indexed = {
    for key, value in var.sl_lang : 
    key => [
        for ndx, rule in value :
        {
            _position   = ndx
            rule = rule
        } 
        ] 
  } 
}
# output sl_lang_indexed {
#     value = local.sl_lang_indexed
# }

# process generic egress pattern
locals {
  sl_lang_egress = {
    for key, value in local.sl_lang_indexed : 
    key => {
        for record in value :
        record._position => {
            _position   = record._position
            _format     = "regexp_lang_egress"
            _src        = record.rule
            #_regexp     = local.regexp_lang_egress

            # try egress generic
            protocol    = format("%s/%s%s:%s%s",
                regex(local.regexp_lang_egress, record.rule)[0], # protocol
                regex(local.regexp_lang_egress, record.rule)[1], # src_min
                regex(local.regexp_lang_egress, record.rule)[2] != "" ? format("-%s",regex(local.regexp_lang_egress, record.rule)[2]) : "", # src_max
                regex(local.regexp_lang_egress, record.rule)[3], # dst_min
                regex(local.regexp_lang_egress, record.rule)[4] != "" ? format("-%s",regex(local.regexp_lang_egress, record.rule)[4]) : ""  # dst_max
            )
            stateless   = regex(local.regexp_lang_egress, record.rule)[5] == "stateless" ? true : false
            src      = null
            dst = regex(local.regexp_lang_egress, record.rule)[6]
            description = can(regex(local.regexp_lang_egress, record.rule)[7]) ? regex(local.regexp_lang_egress, record.rule)[7] : null
        } if can(regex(local.regexp_lang_egress, record.rule))
    } 
  }  
}
# output sl_lang_egress {
#     value = local.sl_lang_egress
# }

# process generic ingress pattern
locals {
  sl_lang_ingress = {
    for key, value in local.sl_lang_indexed : 
    key => {
        for record in value :
        record._position => {
            _position   = record._position
            _format     = "regexp_lang_ingress"
            _src        = record.rule
            #_regexp     = local.regexp_lang_ingress

            # try egress generic
            protocol    = format("%s/%s%s:%s%s",
                regex(local.regexp_lang_ingress, record.rule)[0], # protocol
                regex(local.regexp_lang_ingress, record.rule)[1], # src_min
                regex(local.regexp_lang_ingress, record.rule)[2] != "" ? format("-%s",regex(local.regexp_lang_ingress, record.rule)[2]) : "", # src_max
                regex(local.regexp_lang_ingress, record.rule)[3], # dst_min
                regex(local.regexp_lang_ingress, record.rule)[4] != "" ? format("-%s",regex(local.regexp_lang_ingress, record.rule)[4]) : ""  # dst_max
            )
            stateless   = regex(local.regexp_lang_ingress, record.rule)[5] == "stateless" ? true : false
            src = regex(local.regexp_lang_ingress, record.rule)[6]
            dst = null
            description = can(regex(local.regexp_lang_ingress, record.rule)[7]) ? regex(local.regexp_lang_ingress, record.rule)[7] : null
        } if can(regex(local.regexp_lang_ingress, record.rule))
    } 
  } 
}
# output sl_lang_ingress {
#     value = local.sl_lang_ingress
# }

# process simplified egress pattern
locals {
  sl_lang_egress_dst = {
    for key, value in local.sl_lang_indexed : 
    key => {
        for record in value :
        record._position => {
            _position   = record._position
            _format     = "regexp_lang_egress_dst"
            _src        = record.rule
            #_regexp     = local.regexp_lang_egress_dst

            protocol    = format("%s/%s%s",
                regex(local.regexp_lang_egress_dst, record.rule)[0], # protocol
                regex(local.regexp_lang_egress_dst, record.rule)[1], # dst_min
                regex(local.regexp_lang_egress_dst, record.rule)[2] != "" ? format("-%s",regex(local.regexp_lang_egress_dst, record.rule)[2]) : ""  # dst_max
            )
            stateless   = regex(local.regexp_lang_egress_dst, record.rule)[3] == "stateless" ? true : false
            src      = null
            dst = regex(local.regexp_lang_egress_dst, record.rule)[4]
            description = can(regex(local.regexp_lang_egress_dst, record.rule)[5]) ? regex(local.regexp_lang_egress_dst, record.rule)[5] : null
        } if can(regex(local.regexp_lang_egress_dst, record.rule))
    } 
  } 
}
# output sl_lang_egress_dst {
#     value = local.sl_lang_egress_dst
# }

# process simplified ingress pattern w/o comment
locals {
  sl_lang_ingress_dst = {
    for key, value in local.sl_lang_indexed : 
    key => {
        for record in value :
        record._position => {
            _position   = record._position
            _format     = "regexp_lang_ingress_dst"
            _src        = record.rule
            #_regexp     = local.regexp_lang_ingress_dst

            protocol    = format("%s/%s-%s",
                regex(local.regexp_lang_ingress_dst, record.rule)[0], # protocol
                regex(local.regexp_lang_ingress_dst, record.rule)[1], # dst_min
                regex(local.regexp_lang_ingress_dst, record.rule)[2]  # dst_max
            )
            stateless   = regex(local.regexp_lang_ingress_dst, record.rule)[3] == "stateless" ? true : false
            src = regex(local.regexp_lang_ingress_dst, record.rule)[4]
            dst = null
            description = null
        } if can(regex(local.regexp_lang_ingress_dst, record.rule))
    } 
  } 
}
# output sl_lang_ingress_dst {
#     value = local.sl_lang_ingress_dst
# }

# process simplified ingress pattern
locals {
  sl_lang_ingress_dst_cmt = {
    for key, value in local.sl_lang_indexed : 
    key => {
        for record in value :
        record._position => {
            _position   = record._position
            _format     = "regexp_lang_ingress_dst_cmt"
            _src        = record.rule
            #_regexp     = local.regexp_lang_ingress_dst_cmt

            protocol    = format("%s/%s-%s",
                regex(local.regexp_lang_ingress_dst_cmt, record.rule)[0], # protocol
                regex(local.regexp_lang_ingress_dst_cmt, record.rule)[1], # dst_min
                regex(local.regexp_lang_ingress_dst_cmt, record.rule)[2]  # dst_max
            )
            stateless   = regex(local.regexp_lang_ingress_dst_cmt, record.rule)[3] == "stateless" ? true : false
            src = regex(local.regexp_lang_ingress_dst_cmt, record.rule)[4]
            dst = null
            description = can(regex(local.regexp_lang_ingress_dst_cmt, record.rule)[5]) ? regex(local.regexp_lang_ingress_dst_cmt, record.rule)[5] : null
        } if can(regex(local.regexp_lang_ingress_dst_cmt, record.rule))
    }
  } 
}
# output sl_lang_ingress_dst_cmt {
#     value = local.sl_lang_ingress_dst_cmt
# }

# process simplified ingress icmp pattern with comment
locals {
  sl_lang_icmp_ingress_cmt = {
    for key, value in local.sl_lang_indexed : 
    key => {
        for record in value :
        record._position => {
            _position   = record._position
            _format     = "regexp_lang_icmp_ingress_cmt"
            _src        = record.rule
            #_regexp     = local.regexp_lang_icmp_ingress_cmt

            protocol    = format("icmp/%s.%s",
                regex(local.regexp_lang_icmp_ingress_cmt, record.rule)[0], # type
                regex(local.regexp_lang_icmp_ingress_cmt, record.rule)[1]  # code
            )
            stateless   = regex(local.regexp_lang_icmp_ingress_cmt, record.rule)[2] == "stateless" ? true : false
            
            src = regex(local.regexp_lang_icmp_ingress_cmt, record.rule)[3]
            dst = null
            
            description = regex(local.regexp_lang_icmp_ingress_cmt, record.rule)[4]
        } if can(regex(local.regexp_lang_icmp_ingress_cmt, record.rule))
    }
  } 
}
# output sl_lang_icmp_ingress_cmt {
#     value = local.sl_lang_icmp_ingress_cmt
# }

# process simplified ingress icmp pattern
locals {
  sl_lang_icmp_ingress = {
    for key, value in local.sl_lang_indexed : 
    key => {
        for record in value :
        record._position => {
            _position   = record._position
            _format     = "regexp_lang_icmp_ingress"
            _src        = record.rule
            #_regexp     = local.regexp_lang_icmp_ingress

            protocol    = format("icmp/%s.%s",
                regex(local.regexp_lang_icmp_ingress, record.rule)[0], # type
                regex(local.regexp_lang_icmp_ingress, record.rule)[1]  # code
            )
            stateless   = regex(local.regexp_lang_icmp_ingress, record.rule)[2] == "stateless" ? true : false

            src = regex(local.regexp_lang_icmp_ingress, record.rule)[3]
            dst = null

            description = null
        } if can(regex(local.regexp_lang_icmp_ingress, record.rule))
    }
  } 
}
# output sl_lang_icmp_ingress {
#     value = local.sl_lang_icmp_ingress
# }


# process simplified egress icmp pattern with comment
locals {
  sl_lang_icmp_egress_cmt = {
    for key, value in local.sl_lang_indexed : 
    key => {
        for record in value :
        record._position => {
            _position   = record._position
            _format     = "regexp_lang_icmp_egress_cmt"
            _src        = record.rule
            #_regexp     = local.regexp_lang_icmp_egress_cmt

            protocol    = format("icmp/%s.%s",
                regex(local.regexp_lang_icmp_egress_cmt, record.rule)[0], # type
                regex(local.regexp_lang_icmp_egress_cmt, record.rule)[1]  # code
            )

            stateless   = regex(local.regexp_lang_icmp_egress_cmt, record.rule)[2] == "stateless" ? true : false
            src = null
            dst = regex(local.regexp_lang_icmp_egress_cmt, record.rule)[3]

            description = regex(local.regexp_lang_icmp_egress_cmt, record.rule)[4]
        } if can(regex(local.regexp_lang_icmp_egress_cmt, record.rule))
    }
  } 
}
# output sl_lang_icmp_egress_cmt {
#     value = local.sl_lang_icmp_egress_cmt
# }

# process simplified egress icmp pattern
locals {
  sl_lang_icmp_egress = {
    for key, value in local.sl_lang_indexed : 
    key => {
        for record in value :
        record._position => {
            _position   = record._position
            _format     = "regexp_lang_icmp_egress"
            _src        = record.rule
            #_regexp     = local.regexp_lang_icmp_egress

            protocol    = format("icmp/%s.%s",
                regex(local.regexp_lang_icmp_egress, record.rule)[0], # type
                regex(local.regexp_lang_icmp_egress, record.rule)[1]  # code
            )
            stateless   = regex(local.regexp_lang_icmp_egress, record.rule)[2] == "stateless" ? true : false

            src = null
            dst = regex(local.regexp_lang_icmp_egress, record.rule)[3]

            description = null
        } if can(regex(local.regexp_lang_icmp_egress, record.rule))
    }
  } 
}
# output sl_lang_icmp_egress {
#     value = local.sl_lang_icmp_egress
# }

locals {
  # generate sorted positions for each key
  sl_lang_positions_per_key = {
    for key, value in local.sl_lang_indexed : 
      key =>
      sort(formatlist("%010d", [for rule in value : rule._position]))
  }
}
# output "sl_lang_positions_per_key" {
#    value = local.sl_lang_positions_per_key
# }

locals {
  sl_lang_map = {
    for key, entry in local.sl_lang_indexed :
      key => {
      rules = [
        for position in local.sl_lang_positions_per_key[key]:

            # data is kept in separate data structures because of processing limitations
            # this is a moment when all pieces are collected together
            # Note that each interim data structure keeps distinct set of data,
            # what is guaranteed by processing filters.  
            can(local.sl_lang_egress[key][tonumber(position)])
                ? local.sl_lang_egress[key][tonumber(position)] 
                : can(local.sl_lang_ingress[key][tonumber(position)])
                    ? local.sl_lang_ingress[key][tonumber(position)] 
                    : can(local.sl_lang_egress_dst[key][tonumber(position)])
                        ? local.sl_lang_egress_dst[key][tonumber(position)] 
                        : can(local.sl_lang_ingress_dst[key][tonumber(position)])
                            ? local.sl_lang_ingress_dst[key][tonumber(position)] 
                            : can(local.sl_lang_ingress_dst_cmt[key][tonumber(position)])
                                ? local.sl_lang_ingress_dst_cmt[key][tonumber(position)] 
                                : can(local.sl_lang_icmp_ingress_cmt[key][tonumber(position)])
                                    ? local.sl_lang_icmp_ingress_cmt[key][tonumber(position)] 
                                    : can(local.sl_lang_icmp_ingress[key][tonumber(position)])
                                        ? local.sl_lang_icmp_ingress[key][tonumber(position)] 
                                        : can(local.sl_lang_icmp_egress[key][tonumber(position)])
                                            ? local.sl_lang_icmp_egress[key][tonumber(position)] 
                                            : can(local.sl_lang_icmp_egress_cmt[key][tonumber(position)])
                                                ? local.sl_lang_icmp_egress_cmt[key][tonumber(position)] 
                                                : local.sl_critical_error["error"]
      ]
    } 
  }
}
output "sl_lang_map" {
  value = local.sl_lang_map
}


