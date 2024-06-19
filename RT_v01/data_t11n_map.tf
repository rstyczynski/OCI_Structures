# output rt_cidr {
#   value = local.rt_cidr
# }
locals {
  rt_cidr = local.rt_cidr_step2

  # substitute labels
  rt_cidr_step1 = {
    for route_table, value in local.rt_map : 
    route_table => [
        for ndx, route in value :
        {
          _position   = (ndx * 1000)

          route_table = route_table
          route_type = route.route_type
          route_lang = route.route_lang  
          
          destination_label = route.destination

          destination = can(route.destination) ? route.destination == null ? null : can(
            regex(local.regexp_cidr, route.destination)) ? route.destination : can(
            local.cidrs[route.destination]) ? local.cidrs[route.destination] : route.destination : null

          destination_labeltype = can(route.destination) ? route.destination == null ? null : can(
            regex(local.regexp_cidr, route.destination)) ? "CIDR_BLOCK" : can(
            local.osn_cidrs[route.destination]) ? "SERVICE_CIDR_BLOCK" : can(
            local.global_cidrs[route.destination]) ? "GLOBAL_CIDR_BLOCK" : can(
            var.cidrs[route.destination]) ? "VARIABLE_CIDR_BLOCK" : can(
            local.test_cidrs[route.destination]) ? "TEST_CIDR_BLOCK" : "UNKNOWN_CIDR_BLOCK" : null
                    
          gateway_fqn  = can(route.gateway_fqn) ? route.gateway_fqn : null
          gateway_type = can(route.gateway_type) ? route.gateway_type : null

          description = can(route.description) ? route.description : null
        }
      ]
  }

  # extend multiple CIDRs
  rt_cidr_step2 = {
    for key, value in local.rt_cidr_step1 : 
    key => flatten([
        for route in value : [
          for ndx2, destination in split(";", can(route.destination) ? route.destination == null ? "" : route.destination : null): {
            _position   = route._position + ndx2

            route_table = route.route_table
            route_type = route.route_type  
            route_lang = route.route_lang  

            destination = destination
            destination_label = route.destination_label
            destination_labeltype = route.destination_labeltype
            destination_type = local.labeltype2type[route.destination_labeltype]

            gateway_fqn  = route.gateway_fqn
            gateway_type = route.gateway_type 

            description = route.description

          }
        ]
      ])
  }

}

#
# substitute gateway fqn with ocids. process: IGW, NAT, DRG, PIP, SGW
#
# output rt_gw {
#   value = local.rt_gw
# }
locals {

  rt_gw = local.rt_gw_step2

  # prepare vcn_fqn, knowing that gateway is always associated with the vcn
  rt_gw_step1 = {
    for key, value in local.rt_cidr : 
    key => [
        for route in value :
        {
          _position   = route._position
          
          route_table = route.route_table
          route_type = route.route_type  
          route_lang = route.route_lang  

          destination = route.destination
          destination_label = route.destination_label
          destination_labeltype = route.destination_labeltype
          destination_type = route.destination_type

          description = route.description

          gateway_fqn  = replace(route.gateway_fqn, "../", format("%s/",local.vcn_fqn))
          gateway_type = route.gateway_type
        }
      ]
  }


  //compartment_fqn = data.compartment_fqn != null ? data.compartment_fqn : can(local.locations[data.location_fqn]) ? local.locations[data.location_fqn] : data.location_fqn


  rt_gw_step2 = {
    for key, value in local.rt_gw_step1 : 
    key => [
        for route in value :
        {
          _position   = route._position

          route_table = route.route_table
          route_type = route.route_type  
          route_lang = route.route_lang  
          
          destination = route.destination
          destination_label = route.destination_label
          destination_labeltype = route.destination_labeltype
          destination_type = route.destination_type

          description = route.description

          gateway_fqn  = route.gateway_fqn
          gateway_type = route.gateway_type
          gateway_id = local.ocids[route.gateway_fqn]

          gateway_name = basename(route.gateway_fqn)
          vcn_fqn = dirname(route.gateway_fqn)
        }
      ]
  }

}