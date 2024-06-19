
# Route table

"route1" = [   
    "route 10.1.0.0/16 via DRG /hub1/drg_central /* regular CIDR */",
    "route /spoke2/sub_db via LPG /spoke1/lpg_spoke2 /* CIDR collected from Subnet */",
    "route internet via NAT /spoke1/nat_internet-access /* CIDR specified with label */",
    "route internet via IGW /spoke1/igw_internet-access /* CIDR specified with label */"
],
"route2" = [ 
    "route oci_object_storage via SG /spoke1/sg_osn-storage /* route object storage */",
    "route oci_all_osn_services via SG /spoke1/sg_osn /* route all osn */"
],
"route3" = [ 
    "route oci_object_storage via SG /spoke1/sg_osn-storage /* route object storage */",
    "route internet via NAT /spoke1/nat_internet-access /* CIDR specified with label */",
    "route oci_all_osn_services via SG /spoke1/sg_osn /* route all osn */"
]

Rules:
1. CIDR labels are rendered from local.network_labels
2. Destination_type is rendered from provided CIDR or service name.


# Ideas

when traffic leaves subnet route /spoke2/vcn via PIP /hub/pip_firewall 
when traffic leaves subnet route fallback via PIP /hub/pip_firewall /* fallback means default route */

when traffic leaves subnet route any via PIP /hub/pip_firewall /* any is extended to two routes: subnet's VCN and fallback */

when traffic leaves subnet route any via DRG /drg_central /* hub/spoke */

## DRG attachment route rules

when traffic enters VCN from DRG route /spoke2/vcn via PIP /hub/pip_firewall 
when traffic enters DRG from on_premises route /spoke2/vcn via /hub/vcn

## Syntax no.1

when traffic leaves subnet /reg1/spoke1/sub_app1 route any via DRG /drg_local

when traffic enters DRG /drg_local from VCN /reg1/spoke1 route /reg2/spoke1 via RPC /reg2/drg_local

when traffic enters DRG /drg_local from VCN /reg1/spoke1 route on_premies via /drg_border

when traffic enters DRG /drg_border from RPC /drg_local route on_premies via /hub/vcn_firewall
when traffic enters DRG /drg_border from VC /hub/vc route on_premies via /hub/vcn_firewall

when traffic enters VCN /hub/vcn_firewall from DRG /drg_border route on_premies via PIP pip_firewall

### uff....

when traffic leaves subnet /hub/vcn_firewall route on_premies via VC /hub/vc
when traffic leaves subnet /hub/vcn_firewall route /reg1/spoke1 via RPC /drg_local

## Syntax no.2

traffic from SUBNET /spoke1/sub_app1 heading anywhere route via DRG /drg_local

traffic from VCN /spoke1 heading /reg2/spoke1 route via DRG /drg_local
traffic from VCN /spoke1 heading on_premies route via DRG /drg_border

traffic from DRG /drg_local heading on_premies route via VCN /hub/vcn_firewall


traffic from VC /hub/vc heading on_premies route via VCN /hub/vcn_firewall

traffic from VCN /hub/vcn_firewall heading on_premies route via PIP /hub/vcn_firewall/pip_firewall

traffic from VC /hub/vc heading on_premies route via VCN /hub/vcn_firewall
