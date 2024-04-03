#!/bin/bash

source ../lib/tf_tests.sh

export TF_VAR_security_list='[
  {
      "key": "test1",
      "protocol": "tcp/22",
      "destination": "0.0.0.0/0"
      "description": "ssh for everybody!",
      "stateless": true,
  },
  {
    "key": "test1",
    "protocol": "tcp/8080",
    "destination": "0.0.0.0/0"
  },
  {
      "key": "test1",
      "protocol": "tcp/80-90",
      "destination": "0.0.0.0/0"
  },
  {
      "key": "test1",
      "protocol": "tcp/:1521-1523",
      "destination": "0.0.0.0/0"
  },
  {
      "key": "test1",
      "protocol": "TcP/22:",
      "destination": "0.0.0.0/0"
  },
  {
      "key": "test1",
      "protocol": "TcP/21-22:1521-1523",
      "destination": "0.0.0.0/0"
  },
  {
      "key": "test1",
      "protocol": "icmp/3.4",
      "destination": "0.0.0.0/0"
  },
  {
      "key": "test1",
      "protocol": "icmp/8",
      "destination": "0.0.0.0/0"
  },
  {
      "key": "test1",
      "protocol": "icmp/8",
      "destination": "XXX"
  },
  {
      "key": "test1",
      "protocol": "icmp/8",
      "source": "0.0.0.0/0"
  },
  {
      "key": "test1",
      "protocol": "icmp/8",
      "source": "XXX"
  }
]'

expect_mode=json
output_name=security_list
expect_tf_answer security_list '
[
    {
      "key": "test1",
      "position": 0,
      "description": "ssh for everybody!",
      "stateless": true,
      "source_string": "tcp/22",
      "destination": "0.0.0.0/0",
      "destination_type": "CIDR_BLOCK",
      "source": null,
      "source_type": null,
      "dst_port_max": 22,
      "dst_port_min": 22,
      "protocol": "TCP",
      "src_port_max": null,
      "src_port_min": null,
      "icmp_code": null,
      "icmp_type": null,
      "type": "sl_dst_only"
    },
    {
      "key": "test1",
      "description": null,
      "stateless": null,
        "destination": "0.0.0.0/0",
        "destination_type": "CIDR_BLOCK",
        "source": null,
        "source_type": null,
        "dst_port_max": 8080,
        "dst_port_min": 8080,
        "position": 1,
        "protocol": "TCP",
        "source_string": "tcp/8080",
        "src_port_max": null,
        "src_port_min": null,
        "icmp_code": null,
        "icmp_type": null,
        "type": "sl_dst_only"
    },
    {
      "key": "test1",
      "description": null,
      "stateless": null,
      "destination": "0.0.0.0/0",
      "destination_type": "CIDR_BLOCK",
      "source": null,
      "source_type": null,
      "dst_port_max": 90,
      "dst_port_min": 80,
      "position": 2,
      "protocol": "TCP",
      "source_string": "tcp/80-90",
      "src_port_max": null,
      "src_port_min": null,
      "icmp_code": null,
      "icmp_type": null,
      "type": "sl_dst_only"
    },
    {
      "key": "test1",
      "description": null,
      "stateless": null,
      "destination": "0.0.0.0/0",
      "destination_type": "CIDR_BLOCK",
      "source": null,
      "source_type": null,
      "dst_port_max": 1523,
      "dst_port_min": 1521,
      "position": 3,
      "protocol": "TCP",
      "source_string": "tcp/:1521-1523",
      "src_port_max": null,
      "src_port_min": null,
      "icmp_code": null,
      "icmp_type": null,
      "type": "sl_src_dst"
    },
    {
      "key": "test1",
      "description": null,
      "stateless": null,
      "destination": "0.0.0.0/0",
      "destination_type": "CIDR_BLOCK",
      "source": null,
      "source_type": null,
      "dst_port_max": null,
      "dst_port_min": null,
      "position": 4,
      "protocol": "TCP",
      "source_string": "TcP/22:",
      "src_port_max": 22,
      "src_port_min": 22,
      "icmp_code": null,
      "icmp_type": null,
      "type": "sl_src_dst"
    },
    {
      "key": "test1",
      "description": null,
      "stateless": null,
      "destination": "0.0.0.0/0",
      "destination_type": "CIDR_BLOCK",
      "source": null,
      "source_type": null,
      "dst_port_max": 1523,
      "dst_port_min": 1521,
      "position": 5,
      "protocol": "TCP",
      "source_string": "TcP/21-22:1521-1523",
      "src_port_max": 22,
      "src_port_min": 21,
      "icmp_code": null,
      "icmp_type": null,
      "type": "sl_src_dst"
    },
  {
    "key": "test1",
    "description": null,
    "destination": "0.0.0.0/0",
    "destination_type": "CIDR_BLOCK",
    "source": null,
    "source_type": null,
    "dst_port_max": null,
    "dst_port_min": null,
    "icmp_code": 4,
    "icmp_type": 3,
    "position": 6,
    "protocol": "ICMP",
    "source_string": "icmp/3.4",
    "src_port_max": null,
    "src_port_min": null,
    "stateless": null,
    "type": "sl_icmp"
  },
  {
    "key": "test1",
    "description": null,
    "destination": "0.0.0.0/0",
    "destination_type": "CIDR_BLOCK",
    "source": null,
    "source_type": null,
    "dst_port_max": null,
    "dst_port_min": null,
    "icmp_code": null,
    "icmp_type": 8,
    "position": 7,
    "protocol": "ICMP",
    "source_string": "icmp/8",
    "src_port_max": null,
    "src_port_min": null,
    "stateless": null,
    "type": "sl_icmp"
    },
  {
    "key": "test1",
    "description": null,
    "destination": "XXX",
    "destination_type": "SERVICE_CIDR_BLOCK",
    "source": null,
    "source_type": null,
    "dst_port_max": null,
    "dst_port_min": null,
    "icmp_code": null,
    "icmp_type": 8,
    "position": 8,
    "protocol": "ICMP",
    "source_string": "icmp/8",
    "src_port_max": null,
    "src_port_min": null,
    "stateless": null,
    "type": "sl_icmp"
    },
  {
    "key": "test1",
    "description": null,
    "destination": null,
    "destination_type": null,
    "source": "0.0.0.0/0",
    "source_type": "CIDR_BLOCK",
    "dst_port_max": null,
    "dst_port_min": null,
    "icmp_code": null,
    "icmp_type": 8,
    "position": 9,
    "protocol": "ICMP",
    "source_string": "icmp/8",
    "src_port_max": null,
    "src_port_min": null,
    "stateless": null,
    "type": "sl_icmp"
    },
  {
    "key": "test1",
    "description": null,
    "destination": null,
    "destination_type": null,
    "source": "XXX",
    "source_type": "SERVICE_CIDR_BLOCK",
    "dst_port_max": null,
    "dst_port_min": null,
    "icmp_code": null,
    "icmp_type": 8,
    "position": 10,
    "protocol": "ICMP",
    "source_string": "icmp/8",
    "src_port_max": null,
    "src_port_min": null,
    "stateless": null,
    "type": "sl_icmp"
    }
  ]  
'
unset TF_VAR_security_list
unset output_name

