#!/bin/bash

source ../lib/tf_tests.sh

export TF_VAR_sl_map='
  {
    test1 = {
      rules = [
        {
        "protocol": "tcp/22",
        "destination": "0.0.0.0/0"
        "description": "ssh for everybody!",
        "stateless": true,
        },
        {
          "protocol": "tcp/8080",
          "destination": "0.0.0.0/0"
        }
      ]
    }
  }
'
expect_mode=json
output_name=sl
export TF_VAR_sl_key=test1
expect_tf_answer sl_simple '{
  "test1": {
    "rules": [
      {
        "_position": 0,
        "_source": "tcp/22",
        "_type": "sl_dst_only",
        "description": "ssh for everybody!",
        "destination": "0.0.0.0/0",
        "destination_type": "CIDR_BLOCK",
        "dst_port_max": 22,
        "dst_port_min": 22,
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "TCP",
        "source": null,
        "source_type": null,
        "src_port_max": null,
        "src_port_min": null,
        "stateless": true
      },
      {
        "_position": 1,
        "_source": "tcp/8080",
        "_type": "sl_dst_only",
        "description": null,
        "destination": "0.0.0.0/0",
        "destination_type": "CIDR_BLOCK",
        "dst_port_max": 8080,
        "dst_port_min": 8080,
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "TCP",
        "source": null,
        "source_type": null,
        "src_port_max": null,
        "src_port_min": null,
        "stateless": null
      }
    ]
  }
}
'

# sls with keys: test1, test2 
export TF_VAR_sl_map='
  {
    test1 = {
      rules = [
        {
        "protocol": "tcp/22",
        "destination": "0.0.0.0/0"
        "description": "ssh for everybody!",
        "stateless": true,
        },
        {
          "protocol": "tcp/8080",
          "destination": "0.0.0.0/0"
        },
        {
            "protocol": "tcp/80-90",
            "destination": "0.0.0.0/0"
        },
        {
            "protocol": "tcp/:1521-1523",
            "destination": "0.0.0.0/0"
        },
        {
            "protocol": "TcP/22:",
            "destination": "0.0.0.0/0"
        },
        {
            "protocol": "TcP/21-22:1521-1523",
            "destination": "0.0.0.0/0"
        },
        {
            "protocol": "icmp/3.4",
            "destination": "0.0.0.0/0"
        },
        {
            "protocol": "icmp/8",
            "destination": "0.0.0.0/0"
        }
      ]
    },
    test2 = {
      rules = [
        {
          "protocol": "icmp/8",
          "destination": "XXX"
        },
        {
          "protocol": "icmp/8",
          "source": "0.0.0.0/0"
        },
        {
          "protocol": "icmp/8",
          "source": "XXX"
        }
      ]
    }
  }
'


expect_mode=json
output_name=sl
export TF_VAR_sl_key=test1
expect_tf_answer sl '
{
  "test1": {
    "rules": [
      {
        "_position": 0,
        "_source": "tcp/:1521-1523",
        "_type": "sl_src_dst",
        "description": null,
        "destination": "0.0.0.0/0",
        "destination_type": "CIDR_BLOCK",
        "dst_port_max": 1523,
        "dst_port_min": 1521,
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "TCP",
        "source": null,
        "source_type": null,
        "src_port_max": null,
        "src_port_min": null,
        "stateless": null
      },
      {
        "_position": 1,
        "_source": "TcP/22:",
        "_type": "sl_src_dst",
        "description": null,
        "destination": "0.0.0.0/0",
        "destination_type": "CIDR_BLOCK",
        "dst_port_max": null,
        "dst_port_min": null,
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "TCP",
        "source": null,
        "source_type": null,
        "src_port_max": 22,
        "src_port_min": 22,
        "stateless": null
      },
      {
        "_position": 2,
        "_source": "TcP/21-22:1521-1523",
        "_type": "sl_src_dst",
        "description": null,
        "destination": "0.0.0.0/0",
        "destination_type": "CIDR_BLOCK",
        "dst_port_max": 1523,
        "dst_port_min": 1521,
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "TCP",
        "source": null,
        "source_type": null,
        "src_port_max": 22,
        "src_port_min": 21,
        "stateless": null
      },
      {
        "_position": 3,
        "_source": "tcp/22",
        "_type": "sl_dst_only",
        "description": "ssh for everybody!",
        "destination": "0.0.0.0/0",
        "destination_type": "CIDR_BLOCK",
        "dst_port_max": 22,
        "dst_port_min": 22,
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "TCP",
        "source": null,
        "source_type": null,
        "src_port_max": null,
        "src_port_min": null,
        "stateless": true
      },
      {
        "_position": 4,
        "_source": "tcp/8080",
        "_type": "sl_dst_only",
        "description": null,
        "destination": "0.0.0.0/0",
        "destination_type": "CIDR_BLOCK",
        "dst_port_max": 8080,
        "dst_port_min": 8080,
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "TCP",
        "source": null,
        "source_type": null,
        "src_port_max": null,
        "src_port_min": null,
        "stateless": null
      },
      {
        "_position": 5,
        "_source": "tcp/80-90",
        "_type": "sl_dst_only",
        "description": null,
        "destination": "0.0.0.0/0",
        "destination_type": "CIDR_BLOCK",
        "dst_port_max": 90,
        "dst_port_min": 80,
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "TCP",
        "source": null,
        "source_type": null,
        "src_port_max": null,
        "src_port_min": null,
        "stateless": null
      },
      {
        "_position": 6,
        "_source": "icmp/3.4",
        "_type": "sl_icmp",
        "description": null,
        "destination": "0.0.0.0/0",
        "destination_type": "CIDR_BLOCK",
        "dst_port_max": null,
        "dst_port_min": null,
        "icmp_code": 4,
        "icmp_type": 3,
        "protocol": "ICMP",
        "source": null,
        "source_type": null,
        "src_port_max": null,
        "src_port_min": null,
        "stateless": null
      },
      {
        "_position": 7,
        "_source": "icmp/8",
        "_type": "sl_icmp",
        "description": null,
        "destination": "0.0.0.0/0",
        "destination_type": "CIDR_BLOCK",
        "dst_port_max": null,
        "dst_port_min": null,
        "icmp_code": null,
        "icmp_type": 8,
        "protocol": "ICMP",
        "source": null,
        "source_type": null,
        "src_port_max": null,
        "src_port_min": null,
        "stateless": null
      }
    ]
  },
  "test2": {
    "rules": [
      {
        "_position": 0,
        "_source": "icmp/8",
        "_type": "sl_icmp",
        "description": null,
        "destination": "XXX",
        "destination_type": "SERVICE_CIDR_BLOCK",
        "dst_port_max": null,
        "dst_port_min": null,
        "icmp_code": null,
        "icmp_type": 8,
        "protocol": "ICMP",
        "source": null,
        "source_type": null,
        "src_port_max": null,
        "src_port_min": null,
        "stateless": null
      },
      {
        "_position": 1,
        "_source": "icmp/8",
        "_type": "sl_icmp",
        "description": null,
        "destination": null,
        "destination_type": null,
        "dst_port_max": null,
        "dst_port_min": null,
        "icmp_code": null,
        "icmp_type": 8,
        "protocol": "ICMP",
        "source": "0.0.0.0/0",
        "source_type": "CIDR_BLOCK",
        "src_port_max": null,
        "src_port_min": null,
        "stateless": null
      },
      {
        "_position": 2,
        "_source": "icmp/8",
        "_type": "sl_icmp",
        "description": null,
        "destination": null,
        "destination_type": null,
        "dst_port_max": null,
        "dst_port_min": null,
        "icmp_code": null,
        "icmp_type": 8,
        "protocol": "ICMP",
        "source": "XXX",
        "source_type": "SERVICE_CIDR_BLOCK",
        "src_port_max": null,
        "src_port_min": null,
        "stateless": null
      }
    ]
  }
}
'

export TF_VAR_sl_key=test1
output_name=sl_egress_key
expect_tf_answer sl_egress '
[
  {
    "_position": 0,
    "_source": "tcp/:1521-1523",
    "_type": "sl_src_dst",
    "description": null,
    "destination": "0.0.0.0/0",
    "destination_type": "CIDR_BLOCK",
    "dst_port_max": 1523,
    "dst_port_min": 1521,
    "icmp_code": null,
    "icmp_type": null,
    "protocol": "TCP",
    "src_port_max": null,
    "src_port_min": null,
    "stateless": null
  },
  {
    "_position": 1,
    "_source": "TcP/22:",
    "_type": "sl_src_dst",
    "description": null,
    "destination": "0.0.0.0/0",
    "destination_type": "CIDR_BLOCK",
    "dst_port_max": null,
    "dst_port_min": null,
    "icmp_code": null,
    "icmp_type": null,
    "protocol": "TCP",
    "src_port_max": 22,
    "src_port_min": 22,
    "stateless": null
  },
  {
    "_position": 2,
    "_source": "TcP/21-22:1521-1523",
    "_type": "sl_src_dst",
    "description": null,
    "destination": "0.0.0.0/0",
    "destination_type": "CIDR_BLOCK",
    "dst_port_max": 1523,
    "dst_port_min": 1521,
    "icmp_code": null,
    "icmp_type": null,
    "protocol": "TCP",
    "src_port_max": 22,
    "src_port_min": 21,
    "stateless": null
  },
  {
    "_position": 3,
    "_source": "tcp/22",
    "_type": "sl_dst_only",
    "description": "ssh for everybody!",
    "destination": "0.0.0.0/0",
    "destination_type": "CIDR_BLOCK",
    "dst_port_max": 22,
    "dst_port_min": 22,
    "icmp_code": null,
    "icmp_type": null,
    "protocol": "TCP",
    "src_port_max": null,
    "src_port_min": null,
    "stateless": true
  },
  {
    "_position": 4,
    "_source": "tcp/8080",
    "_type": "sl_dst_only",
    "description": null,
    "destination": "0.0.0.0/0",
    "destination_type": "CIDR_BLOCK",
    "dst_port_max": 8080,
    "dst_port_min": 8080,
    "icmp_code": null,
    "icmp_type": null,
    "protocol": "TCP",
    "src_port_max": null,
    "src_port_min": null,
    "stateless": null
  },
  {
    "_position": 5,
    "_source": "tcp/80-90",
    "_type": "sl_dst_only",
    "description": null,
    "destination": "0.0.0.0/0",
    "destination_type": "CIDR_BLOCK",
    "dst_port_max": 90,
    "dst_port_min": 80,
    "icmp_code": null,
    "icmp_type": null,
    "protocol": "TCP",
    "src_port_max": null,
    "src_port_min": null,
    "stateless": null
  },
  {
    "_position": 6,
    "_source": "icmp/3.4",
    "_type": "sl_icmp",
    "description": null,
    "destination": "0.0.0.0/0",
    "destination_type": "CIDR_BLOCK",
    "dst_port_max": null,
    "dst_port_min": null,
    "icmp_code": 4,
    "icmp_type": 3,
    "protocol": "ICMP",
    "src_port_max": null,
    "src_port_min": null,
    "stateless": null
  },
  {
    "_position": 7,
    "_source": "icmp/8",
    "_type": "sl_icmp",
    "description": null,
    "destination": "0.0.0.0/0",
    "destination_type": "CIDR_BLOCK",
    "dst_port_max": null,
    "dst_port_min": null,
    "icmp_code": null,
    "icmp_type": 8,
    "protocol": "ICMP",
    "src_port_max": null,
    "src_port_min": null,
    "stateless": null
  }
]
'

export TF_VAR_sl_key=test2
expect_mode=json
output_name=sl_ingress_key
expect_tf_answer sl_ingress '
[
  {
    "_position": 1,
    "_source": "icmp/8",
    "_type": "sl_icmp",
    "description": null,
    "destination": null,
    "destination_type": null,
    "dst_port_max": null,
    "dst_port_min": null,
    "icmp_code": null,
    "icmp_type": 8,
    "protocol": "ICMP",
    "source": "0.0.0.0/0",
    "source_type": "CIDR_BLOCK",
    "src_port_max": null,
    "src_port_min": null,
    "stateless": null
  },
  {
    "_position": 2,
    "_source": "icmp/8",
    "_type": "sl_icmp",
    "description": null,
    "destination": null,
    "destination_type": null,
    "dst_port_max": null,
    "dst_port_min": null,
    "icmp_code": null,
    "icmp_type": 8,
    "protocol": "ICMP",
    "source": "XXX",
    "source_type": "SERVICE_CIDR_BLOCK",
    "src_port_max": null,
    "src_port_min": null,
    "stateless": null
  }
]
'
unset TF_VAR_sl_map
unset TF_VAR_sl_key
unset output_name
unset expect_mode

