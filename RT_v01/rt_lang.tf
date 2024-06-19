variable rt_lang {
    default = {
        "vcn_route1" = [   
            "vcn route 10.1.0.1/32 via DRG /hub1/drg_central",
            "vcn route 10.1.0.2/32 via DRG /hub1/drg_central ",
            "vcn route 10.1.0.3/32 via DRG /hub1/drg_central /* regular CIDR */",
            "v_(error-here!)_cn route /spoke2/sub_db via LPG /spoke1/lpg_spoke2 /* CIDR collected from Subnet */",
            "vcn route internet via NAT /spoke1/nat_internet-access /* CIDR specified with label */",
            "vcn route _test.label_multiple via IGW /spoke1/igw_internet-access /* CIDR specified with test label */"
        ],
        "vcn_route2" = [
            "vcn route osn_object_storage via SGW /spoke1/sg_osn-storage /* route object storage */",
            "vcn route osn_all_osn_services via SGW /spoke1/sg_osn /* route all osn */"
        ],
        "drg_route1" = [   
            "drg route 10.1.0.1/32 via att_spoke1",
            "drg route 10.1.0.2/32 via att_spoke2",
            "drg route 10.1.0.3/32 via att_spoke3 /* regular CIDR */",
            "drg route /spoke2/sub_db via att_spoke2 /* CIDR collected from Subnet */",
            "drg route internet via att_spoke_public /* CIDR specified with label */",
            "drg route _test.label_multiple via att_spoke_public /* CIDR specified with test label */"
        ],
        "drg_route2" = [ 
            "drg route osn_object_storage via att_spoke_public /* route object storage */",
            "drg route osn_all_osn_services via att_spoke_public /* route all osn */"
        ]
    }

    type = map(list(string))
}

locals {
    rt_lang = var.rt_lang
}

# output regexp_route {
#     value = local.regexp_route
# }
# output rt_processed {
#     value = local.rt_processed
# }
locals {
    # Trick. Regex markers are used to make regex string handling easier 
    regexp_marker = "/\\|\\w+\\|/"
    regexp_vcn_route = format(replace("vcn route\\s+|CIDR|%s\\s+via\\s+|GATEWAYTYPE|%s\\s+|GATEWAYFQN|%s\\s*|COMMENT|%s",local.regexp_marker,""), local.regexp_label, local.regexp_gateway, local.regexp_label, local.regexp_comment_option)
    regexp_drg_route = format(replace("drg route\\s+|CIDR|%s\\s+via\\s+|GATEWAYFQN|%s\\s*|COMMENT|%s",local.regexp_marker,""), local.regexp_label, local.regexp_label, local.regexp_comment_option)
        
    rt_processed = merge(local.rt_vcn_clean, local.rt_drg_clean)

    rt_vcn = {for route_table, routes in local.rt_lang:
        
        route_table => [for ndx, route in routes: {
          route_table = route_table
          route_lang = route
          route_type = "VCN"

          destination = regex(local.regexp_vcn_route,route)[0]
          description = regex(local.regexp_vcn_route,route)[3]

          gateway_fqn  = regex(local.regexp_vcn_route,route)[2]
          gateway_type = regex(local.regexp_vcn_route,route)[1]         
        } if can(regex(local.regexp_vcn_route,route))
        ] 
    }
    rt_vcn_clean = { for key, value in local.rt_vcn : key => value if value != null && value != [] }

    rt_drg = {for route_table, routes in local.rt_lang:
        
        route_table => [for ndx, route in routes: {
          _position   = ndx * 1000 # multiplied by 1000 to make space for labels with more than one CIDR. 1000 is of course unreachable limit.....
          
          route_table = route_table
          route_lang = route
          route_type = "DRG"

          destination = regex(local.regexp_drg_route,route)[0]
          description = regex(local.regexp_drg_route,route)[2]

          gateway_type = "DRG_ATTACHEMENT"
          gateway_fqn  = regex(local.regexp_drg_route,route)[1]     
        } if can(regex(local.regexp_drg_route,route))
        ] 
    }

    rt_drg_clean = { for key, value in local.rt_drg : key => value if value != null && value != [] }

    # catch not recognised routes
    rt_error_tmp = {for route_table, routes in local.rt_lang:
        
        route_table => [for ndx, route in routes: {
          _position   = ndx * 1000 # multiplied by 1000 to make space for labels with more than one CIDR. 1000 is of course unreachable limit.....
          
          route_table = route_table
          route_lang = route
          route_type = "UNKNOWN"

          destination = "UNKNOWN"
          description = "UNKNOWN"

          gateway_fqn  = "UNKNOWN"
          gateway_type = "UNKNOWN"       
        } if ! can(regex(local.regexp_vcn_route,route)) && ! can(regex(local.regexp_drg_route,route))
        ] 
    }

    # TODO Prerequisite check that rt_error is [] for route_table / drg route_tqble resources 
    # Rule. Errors repoted by ruto preprocessing stops resource creation by precondition.
    rt_error = { for key, value in local.rt_error_tmp : key => value if value != null && value != [] }

}

output rt_errors {
    value = local.rt_error
}
