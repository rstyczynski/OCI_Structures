# Route table

rt1 = [
    "0.0.0.0/0 via DRG1 /* access to internet via DRG */",
    "0.0.0.0/0 via LPG1",
    "0.0.0.0/0 via IP1",
    "all-services via SG1"
    "project_eldo_dev1 via DRG1"
]

Rules:
1. sub-project_eldo_dev1 is converted to CIDR via network devices data map.
2. Destination_type is rendered from provided CIDR or service name.
