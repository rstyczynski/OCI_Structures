variable rt_map {
    default = {
        "route_table1" = [
            {
                route_type = "VCN"

                destination = "0.0.0.0/0"

                gateway_type = "IGW"
                gateway_fqn = "../igw_general"

                description = "Internet access"
            },
            {
                route_type = "VCN"

                destination = "all"
                gateway_type = "NAT"
                gateway_fqn = "/hub/vcn_main/nat_general"

                description = "Internet NAT access"
            },
            {
                route_type = "VCN"

                destination = "osn_all_osn_services"
                gateway_type = "SGW"
                gateway_fqn = "/hub/vcn_main/sgw_general"

                description = "OSN access"
            }
        ],

        "route_table2" = [
            {
                route_type = "VCN"

                destination = "1.0.0.0/16"
                gateway_type = "DRG"
                gateway_fqn = "/spoke1/vcn_main/drg_local"

                description = "Hub access"
            },
            {
                route_type = "VCN"

                destination = "1.0.0.0/16;128.0.0.0/16"
                gateway_type = "DRG"
                gateway_fqn = "/spoke1/vcn_main/drg_local"

                description = "Hub access to multiple destinations"
            },
            {
                route_type = "VCN"
                
                destination = "128.0.0.0/16"
                gateway_type = "PIP"
                gateway_fqn = "/spoke1/vcn_main/pip_gateway1"

                description = "Private IP access"
            }
        ]
    }

    type = map(list(object({
        route_type = string
        destination = string
        gateway_type = string
        gateway_fqn = string
        description = string
    })))
}

locals {
  labeltype2type = {
  CIDR_BLOCK = "CIDR_BLOCK",
  SERVICE_CIDR_BLOCK = "SERVICE_CIDR_BLOCK",
  GLOBAL_CIDR_BLOCK = "CIDR_BLOCK",
  VARIABLE_CIDR_BLOCK = "CIDR_BLOCK",
  TEST_CIDR_BLOCK = "CIDR_BLOCK",
  UNKNOWN_CIDR_BLOCK = "UNKNOWN_CIDR_BLOCK",
  }
}

variable data_format {
    default = "rt_lang"

    type = string
}
#
# map variables to locals
#
locals {
    data_format = var.data_format
    rt_map = local.data_format == "rt_map" ? var.rt_map : local.data_format == "rt_lang" ? local.rt_processed : null
}

#
# known networks map. Register here CIDR labels
#
variable cidrs {
    type = map(string)
    default = {
        "on_premises" = "192.0.0.0/8"
    }
}

variable ocids {
    type = map(string)
    default = {
        "/cmp_test/vcn_test/igw_general" = "ocid1.igw1"
        "/hub/vcn_main/igw_general" = "ocid1.igw2"
        "/hub/vcn_main/nat_general" = "ocid1.nat"
        "/hub/vcn_main/sgw_general" = "ocid1.sgw"
        "/spoke1/vcn_main/drg_local" = "ocid1.drg"
        "/spoke1/vcn_main/pip_gateway1" = "ocid1.pip"
        "/hub1/drg_central" = "ocid2.hub1_drg"
        "/spoke1/sg_osn" = "ocid2.spoke1.sg_osn"
        "/spoke1/igw_internet" = "ocid2.spoke1.igw_internet"
        "/spoke1/nat_internet" = "ocid2.spoke1.nat_internet"
        "/spoke1/lpg_spoke2" = "ocid2.spoke1.lpg_spoke2"
        "att_spoke_public" = "ocid2.att_spoke_public"
        "att_spoke1" = "ocid2.att_spoke1"
        "att_spoke2" = "ocid2.att_spoke2"
        "att_spoke3" = "ocid2.att_spoke3"
    }
}

variable vcn_fqn {
    type = string

    default = "/cmp_test/vcn_test"
}

locals {
    vcn_fqn = var.vcn_fqn

    ocids = var.ocids

    global_cidrs = {
        "all" = "0.0.0.0/0",
        "internet" = "0.0.0.0/0"
    }

    osn_cidrs = {
        "osn_object_storage" = "osn_object_storage",
        "osn_all_osn_services" = "osn_all_osn_services"
    }

    test_cidrs = {
      "_test.label_multiple" = "1.2.3.4/5;6.7.8.9/10"
    }

    # var.cidrs is at the end to be able to overwrite default values 
    cidrs = merge(local.global_cidrs, local.osn_cidrs, local.test_cidrs, var.cidrs)
}   

output cidrs {
  value = local.cidrs
}

#
# module responses
#
output rt_response {
  value = local.rt_gw
}


