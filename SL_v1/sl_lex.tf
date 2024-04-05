variable "sl_lex" {
  type = map(list(string))

  default = {
      "demo1" = [
        "TcP/21-22:1521-1523 >> on_premises /* DB for some of you */",
        "internet      >> uDP/20000-30000:80-90 /* HTTP over UDP for some of you */",
        "tcp/:1521-1523 > 0.0.0.0/0",
        "0.0.0.0/0      >> uDP/22-23 /* strange ingress udp */",
        "tcp/22         >> 0.0.0.0/0 /* ssh for all! */",
        "0.0.0.0/0      > TcP/21-22:1521-1523 /* DB for everyone */" ,
        "tcp/80-90      >  0.0.0.0/0 /* stateless extended http */",
        "tcp/:22         >> 0.0.0.0/0 /* ssh for all! */",
        "0.0.0.0/0      >> uDP/222-223",
      ],
      "demo2" = [
        "icmp/3.4       >> 0.0.0.0/0 /* egress icmp type 3, code 4 */",
        "0.0.0.0/0      >> icmp/8", 
        "0.0.0.0/0      >> icmp/1. /* icmp type 1 */",
        "icmp/3.        > 0.0.0.0/0",
        "0.0.0.0/0      > icmp/8.1"        
        ]
      }
}
// output sl_lex {
//     value = var.sl_lex
// }


#  pattern to decode lexical rule
locals {
    regexp_egress = format("^%s\\s*%s\\s*%s\\s*%s",local.regexp_ip_ports_full, local.regexp_state, local.regexp_label, local.regexp_comment_option)
    regexp_ingress = format("^%s\\s*%s\\s*%s\\s*%s",local.regexp_label, local.regexp_state, local.regexp_ip_ports_full, local.regexp_comment_option)
}

# patterns for special case of dst only
locals {
    regexp_egress_dst = format("^%s\\s*%s\\s*%s\\s*%s",local.regexp_ip_ports_dst, local.regexp_state, local.regexp_label, local.regexp_comment_option)
    // regexp_ingress_dst_cmt takes full syntax with comments
    // regexp_ingress_dst is ended by $
    // both are workaround for lack of knowledge how to forbid ':' character after ports.
    // w/o above ingress_dst regexp matches generic regexp_ingress
    regexp_ingress_dst_cmt =  format("^%s\\s*%s\\s*%s\\s*%s",local.regexp_label, local.regexp_state, local.regexp_ip_ports_dst, local.regexp_comment)
    regexp_ingress_dst = format("^%s\\s*%s\\s*%s\\s*%s",local.regexp_label, local.regexp_state, local.regexp_ip_ports_dst, local.regexp_eol)
}

# patterns for icmp
locals {
    regexp_icmp_egress = format("^%s\\s*%s\\s*%s\\s*%s",local.regexp_icmp_tc, local.regexp_state, local.regexp_label, local.regexp_eol)
    regexp_icmp_egress_cmt = format("^%s\\s*%s\\s*%s\\s*%s",local.regexp_icmp_tc, local.regexp_state, local.regexp_label, local.regexp_comment)
    regexp_icmp_ingress = format("^%s\\s*%s\\s*%s\\s*%s",local.regexp_label, local.regexp_state, local.regexp_icmp_tc, local.regexp_eol)
    regexp_icmp_ingress_cmt = format("^%s\\s*%s\\s*%s\\s*%s",local.regexp_label, local.regexp_state, local.regexp_icmp_tc, local.regexp_comment)
}

# add index variable to keep order of records
# it's needed as processing is implemented for subsets of the list
# having index field, it's possible to keep original order in final list
locals {
  sl_lex_indexed = {
    for key, value in var.sl_lex : 
    key => [
        for ndx, rule in value :
        {
            _position   = ndx
            rule = rule
        } 
        ] 
  } 
}
// output sl_lex_indexed {
//     value = local.sl_lex_indexed
// }

# process generic egress pattern
locals {
  sl_lex_egress = {
    for key, value in local.sl_lex_indexed : 
    key => {
        for record in value :
        record._position => {
            _position   = record._position
            _format     = "regexp_egress"
            _src        = record.rule
            //_regexp     = local.regexp_egress

            # try egress generic
            protocol    = format("%s/%s%s:%s%s",
                regex(local.regexp_egress, record.rule)[0], # protocol
                regex(local.regexp_egress, record.rule)[1], # src_min
                regex(local.regexp_egress, record.rule)[2] != "" ? format("-%s",regex(local.regexp_egress, record.rule)[2]) : "", # src_max
                regex(local.regexp_egress, record.rule)[3], # dst_min
                regex(local.regexp_egress, record.rule)[4] != "" ? format("-%s",regex(local.regexp_egress, record.rule)[4]) : ""  # dst_max
            )
            src      = null
            dst = regex(local.regexp_egress, record.rule)[6]
            description = regex(local.regexp_egress, record.rule)[7]
            stateless   = regex(local.regexp_egress, record.rule)[5] == ">>" ? false : regex(local.regexp_egress, record.rule)[5] == ">" ? true : null
        } if can(regex(local.regexp_egress, record.rule))
    } 
  } 
}
// output sl_lex_egress {
//     value = local.sl_lex_egress
// }

# process generic ingress pattern
locals {
  sl_lex_ingress = {
    for key, value in local.sl_lex_indexed : 
    key => {
        for record in value :
        record._position => {
            _position   = record._position
            _format     = "regexp_ingress"
            _src        = record.rule
            //_regexp     = local.regexp_ingress

            # try egress generic
            protocol    = format("%s/%s%s:%s%s",
                regex(local.regexp_ingress, record.rule)[2], # protocol
                regex(local.regexp_ingress, record.rule)[3], # src_min
                regex(local.regexp_ingress, record.rule)[4] != "" ? format("-%s",regex(local.regexp_ingress, record.rule)[4]) : "", # src_max
                regex(local.regexp_ingress, record.rule)[5], # dst_min
                regex(local.regexp_ingress, record.rule)[6] != "" ? format("-%s",regex(local.regexp_ingress, record.rule)[6]) : ""  # dst_max
            )
            src = regex(local.regexp_ingress, record.rule)[0]
            dst = null
            description = regex(local.regexp_ingress, record.rule)[7]
            stateless   = regex(local.regexp_ingress, record.rule)[1] == ">>" ? false : regex(local.regexp_ingress, record.rule)[1] == ">" ? true : null
        } if can(regex(local.regexp_ingress, record.rule))
    } 
  } 
}
// output sl_lex_ingress {
//     value = local.sl_lex_ingress
// }

# process simplified egress pattern
locals {
  sl_lex_egress_dst = {
    for key, value in local.sl_lex_indexed : 
    key => {
        for record in value :
        record._position => {
            _position   = record._position
            _format     = "regexp_egress_dst"
            _src        = record.rule
            //_regexp     = local.regexp_egress_dst

            protocol    = format("%s/%s%s",
                regex(local.regexp_egress_dst, record.rule)[0], # protocol
                regex(local.regexp_egress_dst, record.rule)[1], # dst_min
                regex(local.regexp_egress_dst, record.rule)[2] != "" ? format("-%s",regex(local.regexp_egress_dst, record.rule)[2]) : ""  # dst_max
            )
            src      = null
            dst = regex(local.regexp_egress_dst, record.rule)[4]
            description = regex(local.regexp_egress_dst, record.rule)[5]
            stateless   = regex(local.regexp_egress_dst, record.rule)[3] == ">>" ? false : regex(local.regexp_egress_dst, record.rule)[3] == ">" ? true : null
        } if can(regex(local.regexp_egress_dst, record.rule))
    } 
  } 
}
// output sl_lex_egress_dst {
//     value = local.sl_lex_egress_dst
// }

# process simplified ingress pattern w/o comment
locals {
  sl_lex_ingress_dst = {
    for key, value in local.sl_lex_indexed : 
    key => {
        for record in value :
        record._position => {
            _position   = record._position
            _format     = "regexp_ingress_dst"
            _src        = record.rule
            //_regexp     = local.regexp_ingress_dst

            protocol    = format("%s/%s-%s",
                regex(local.regexp_ingress_dst, record.rule)[2], # protocol
                regex(local.regexp_ingress_dst, record.rule)[3], # dst_min
                regex(local.regexp_ingress_dst, record.rule)[4]  # dst_max
            )
            src = regex(local.regexp_ingress_dst, record.rule)[0]
            dst = null
            description = null
            stateless   = regex(local.regexp_ingress_dst, record.rule)[1] == ">>" ? false : regex(local.regexp_ingress_dst, record.rule)[1] == ">" ? true : null
        } if can(regex(local.regexp_ingress_dst, record.rule))
    } 
  } 
}
// output sl_lex_ingress_dst {
//     value = local.sl_lex_ingress_dst
// }

# process simplified ingress pattern
locals {
  sl_lex_ingress_dst_cmt = {
    for key, value in local.sl_lex_indexed : 
    key => {
        for record in value :
        record._position => {
            _position   = record._position
            _format     = "regexp_ingress_dst"
            _src        = record.rule
            //_regexp     = local.regexp_ingress_dst_cmt

            protocol    = format("%s/%s-%s",
                regex(local.regexp_ingress_dst_cmt, record.rule)[2], # protocol
                regex(local.regexp_ingress_dst_cmt, record.rule)[3], # dst_min
                regex(local.regexp_ingress_dst_cmt, record.rule)[4]  # dst_max
            )
            src = regex(local.regexp_ingress_dst_cmt, record.rule)[0]
            dst = null
            description = regex(local.regexp_ingress_dst_cmt, record.rule)[5]
            stateless   = regex(local.regexp_ingress_dst_cmt, record.rule)[1] == ">>" ? false : regex(local.regexp_ingress_dst_cmt, record.rule)[1] == ">" ? true : null
        } if can(regex(local.regexp_ingress_dst_cmt, record.rule))
    }
  } 
}
// output sl_lex_ingress_dst_cmt {
//     value = local.sl_lex_ingress_dst_cmt
// }

# process simplified ingress icmp pattern with comment
locals {
  sl_lex_icmp_ingress_cmt = {
    for key, value in local.sl_lex_indexed : 
    key => {
        for record in value :
        record._position => {
            _position   = record._position
            _format     = "regexp_icmp_ingress_cmt"
            _src        = record.rule
            //_regexp     = local.regexp_icmp_ingress_cmt

            protocol    = format("icmp/%s.%s",
                regex(local.regexp_icmp_ingress_cmt, record.rule)[2], # type
                regex(local.regexp_icmp_ingress_cmt, record.rule)[3]  # code
            )
            src = regex(local.regexp_icmp_ingress_cmt, record.rule)[0]
            dst = null
            description = regex(local.regexp_icmp_ingress_cmt, record.rule)[4]
            stateless   = regex(local.regexp_icmp_ingress_cmt, record.rule)[1] == ">>" ? false : regex(local.regexp_icmp_ingress_cmt, record.rule)[1] == ">" ? true : null
        } if can(regex(local.regexp_icmp_ingress_cmt, record.rule))
    }
  } 
}
// output sl_lex_icmp_ingress_cmt {
//     value = local.sl_lex_icmp_ingress_cmt
// }

# process simplified ingress icmp pattern
locals {
  sl_lex_icmp_ingress = {
    for key, value in local.sl_lex_indexed : 
    key => {
        for record in value :
        record._position => {
            _position   = record._position
            _format     = "regexp_icmp_ingress"
            _src        = record.rule
            //_regexp     = local.regexp_icmp_ingress

            protocol    = format("icmp/%s.%s",
                regex(local.regexp_icmp_ingress, record.rule)[2], # type
                regex(local.regexp_icmp_ingress, record.rule)[3]  # code
            )
            src = regex(local.regexp_icmp_ingress, record.rule)[0]
            dst = null
            description = null
            stateless   = regex(local.regexp_icmp_ingress, record.rule)[1] == ">>" ? false : regex(local.regexp_icmp_ingress, record.rule)[1] == ">" ? true : null
        } if can(regex(local.regexp_icmp_ingress, record.rule))
    }
  } 
}
// output sl_lex_icmp_ingress {
//     value = local.sl_lex_icmp_ingress
// }


# process simplified egress icmp pattern with comment
locals {
  sl_lex_icmp_egress_cmt = {
    for key, value in local.sl_lex_indexed : 
    key => {
        for record in value :
        record._position => {
            _position   = record._position
            _format     = "regexp_icmp_egress_cmt"
            _src        = record.rule
            //_regexp     = local.regexp_icmp_egress_cmt

            protocol    = format("icmp/%s.%s",
                regex(local.regexp_icmp_egress_cmt, record.rule)[0], # type
                regex(local.regexp_icmp_egress_cmt, record.rule)[1]  # code
            )
            src = null
            dst = regex(local.regexp_icmp_egress_cmt, record.rule)[3]

            description = regex(local.regexp_icmp_egress_cmt, record.rule)[4]
            stateless   = regex(local.regexp_icmp_egress_cmt, record.rule)[2] == ">>" ? false : regex(local.regexp_icmp_egress_cmt, record.rule)[2] == ">" ? true : null

        } if can(regex(local.regexp_icmp_egress_cmt, record.rule))
    }
  } 
}
// output sl_lex_icmp_egress_cmt {
//     value = local.sl_lex_icmp_egress_cmt
// }

# process simplified egress icmp pattern
locals {
  sl_lex_icmp_egress = {
    for key, value in local.sl_lex_indexed : 
    key => {
        for record in value :
        record._position => {
            _position   = record._position
            _format     = "regexp_icmp_egress"
            _src        = record.rule
            //_regexp     = local.regexp_icmp_egress

            protocol    = format("icmp/%s.%s",
                regex(local.regexp_icmp_egress, record.rule)[0], # type
                regex(local.regexp_icmp_egress, record.rule)[1]  # code
            )
            src = null
            dst = regex(local.regexp_icmp_egress, record.rule)[3]

            description = null
            stateless   = regex(local.regexp_icmp_egress, record.rule)[2] == ">>" ? false : regex(local.regexp_icmp_egress, record.rule)[2] == ">" ? true : null
        } if can(regex(local.regexp_icmp_egress, record.rule))
    }
  } 
}
// output sl_lex_icmp_egress {
//     value = local.sl_lex_icmp_egress
// }

locals {
  // generate sorted positions for each key
  sl_lex_positions_per_key = {
    for key, value in local.sl_lex_indexed : 
      key =>
      sort(formatlist("%010d", [for rule in value : rule._position]))
  }
}
// output "sl_lex_positions_per_key" {
//   value = local.sl_lex_positions_per_key
// }

locals {
  sl_lex_map = {
    for key, entry in local.sl_lex_indexed :
      key => {
      rules = [
        for position in local.sl_lex_positions_per_key[key]:

            // data is kept in separate data structures because of processing limitations
            // this is a moment when all pieces are collected together
            // Note that each interim data structure keeps distinct set of data,
            // what is guaranteed by processing filters.  
            can(local.sl_lex_egress[key][tonumber(position)])
                ? local.sl_lex_egress[key][tonumber(position)] 
                : can(local.sl_lex_ingress[key][tonumber(position)])
                    ? local.sl_lex_ingress[key][tonumber(position)] 
                    : can(local.sl_lex_egress_dst[key][tonumber(position)])
                        ? local.sl_lex_egress_dst[key][tonumber(position)] 
                        : can(local.sl_lex_ingress_dst[key][tonumber(position)])
                            ? local.sl_lex_ingress_dst[key][tonumber(position)] 
                            : can(local.sl_lex_ingress_dst_cmt[key][tonumber(position)])
                                ? local.sl_lex_ingress_dst_cmt[key][tonumber(position)] 
                                : can(local.sl_lex_icmp_ingress_cmt[key][tonumber(position)])
                                    ? local.sl_lex_icmp_ingress_cmt[key][tonumber(position)] 
                                    : can(local.sl_lex_icmp_ingress[key][tonumber(position)])
                                        ? local.sl_lex_icmp_ingress[key][tonumber(position)] 
                                        : can(local.sl_lex_icmp_egress[key][tonumber(position)])
                                            ? local.sl_lex_icmp_egress[key][tonumber(position)] 
                                            : can(local.sl_lex_icmp_egress_cmt[key][tonumber(position)])
                                                ? local.sl_lex_icmp_egress_cmt[key][tonumber(position)] 
                                                : local.sl_critical_error["error"]
      ]
    } 
  }
}
output "sl_lex_map" {
  value = local.sl_lex_map
}


