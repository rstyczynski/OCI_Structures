#!/bin/bash

source ../lib/tf_tests.sh


echo '============================='
echo '====== map mode'
echo '============================='

export TF_VAR_data_format="sl_map"

export TF_VAR_sl_map='
  {
    test1 = {
      rules = [
        {
        "protocol": "tcp/22",
        "dst": "0.0.0.0/0"
        "description": "ssh for everybody!",
        "stateless": "true",
        },
        {
          "protocol": "tcp/8080",
          "dst": "all_services"
        }
      ]
    }
  }
'
expect_mode=json
output_name=sl_cislz
export TF_VAR_sl_key=test1
# parameter is expected json
# take it executing:
# expect_tf_answer sl_simple ''; show_received_json
expect_tf_answer sl_simple '
{
  "test1": {
    "rules": [
      {
        "_position": 0,
        "_source": "tcp/22",
        "_type": "sl_dst_only",
        "description": "ssh for everybody!",
        "dst": "0.0.0.0/0",
        "dst_type": "CIDR_BLOCK",
        "dst_port_max": 22,
        "dst_port_min": 22,
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "TCP",
        "src": null,
        "src_type": null,
        "src_port_max": null,
        "src_port_min": null,
        "stateless": "true"
      },
      {
        "_position": 1,
        "_source": "tcp/8080",
        "_type": "sl_dst_only",
        "description": null,
        "dst": "all_services",
        "dst_type": "SERVICE_CIDR_BLOCK",
        "dst_port_max": 8080,
        "dst_port_min": 8080,
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "TCP",
        "src": null,
        "src_type": null,
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
        "dst": "0.0.0.0/0"
        "description": "ssh for everybody!",
        "stateless": "true",
        },
        {
          "protocol": "tcp/8080",
          "dst": "0.0.0.0/0"
        },
        {
            "protocol": "tcp/80-90",
            "dst": "0.0.0.0/0"
        },
        {
            "protocol": "tcp/:1521-1523",
            "dst": "0.0.0.0/0"
        },
        {
            "protocol": "TcP/22:",
            "dst": "0.0.0.0/0"
        },
        {
            "protocol": "TcP/21-22:1521-1523",
            "dst": "0.0.0.0/0"
        },
        {
            "protocol": "icmp/3.4",
            "dst": "0.0.0.0/0"
        },
        {
            "protocol": "icmp/8",
            "dst": "0.0.0.0/0"
        }
      ]
    },
    test2 = {
      rules = [
        {
          "protocol": "icmp/8",
          "dst": "all_services"
        },
        {
          "protocol": "icmp/8",
          "src": "0.0.0.0/0"
        },
        {
          "protocol": "icmp/8",
          "src": "all_services"
        }
      ]
    }
  }
'

expect_mode=json
output_name=sl_cislz
export TF_VAR_sl_key=test1
# parameter is expected json
# take it executing:
# expect_tf_answer sl ''; show_received_json
expect_tf_answer sl_cislz '{
  "test1": {
    "rules": [
      {
        "_position": 0,
        "_source": "tcp/22",
        "_type": "sl_dst_only",
        "description": "ssh for everybody!",
        "dst": "0.0.0.0/0",
        "dst_port_max": 22,
        "dst_port_min": 22,
        "dst_type": "CIDR_BLOCK",
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "TCP",
        "src": null,
        "src_port_max": null,
        "src_port_min": null,
        "src_type": null,
        "stateless": "true"
      },
      {
        "_position": 1,
        "_source": "tcp/8080",
        "_type": "sl_dst_only",
        "description": null,
        "dst": "0.0.0.0/0",
        "dst_port_max": 8080,
        "dst_port_min": 8080,
        "dst_type": "CIDR_BLOCK",
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "TCP",
        "src": null,
        "src_port_max": null,
        "src_port_min": null,
        "src_type": null,
        "stateless": null
      },
      {
        "_position": 2,
        "_source": "tcp/80-90",
        "_type": "sl_dst_only",
        "description": null,
        "dst": "0.0.0.0/0",
        "dst_port_max": 90,
        "dst_port_min": 80,
        "dst_type": "CIDR_BLOCK",
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "TCP",
        "src": null,
        "src_port_max": null,
        "src_port_min": null,
        "src_type": null,
        "stateless": null
      },
      {
        "_position": 3,
        "_source": "tcp/:1521-1523",
        "_type": "sl_src_dst",
        "description": null,
        "dst": "0.0.0.0/0",
        "dst_port_max": 1523,
        "dst_port_min": 1521,
        "dst_type": "CIDR_BLOCK",
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "TCP",
        "src": null,
        "src_port_max": null,
        "src_port_min": null,
        "src_type": null,
        "stateless": null
      },
      {
        "_position": 4,
        "_source": "TcP/22:",
        "_type": "sl_src_dst",
        "description": null,
        "dst": "0.0.0.0/0",
        "dst_port_max": null,
        "dst_port_min": null,
        "dst_type": "CIDR_BLOCK",
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "TCP",
        "src": null,
        "src_port_max": 22,
        "src_port_min": 22,
        "src_type": null,
        "stateless": null
      },
      {
        "_position": 5,
        "_source": "TcP/21-22:1521-1523",
        "_type": "sl_src_dst",
        "description": null,
        "dst": "0.0.0.0/0",
        "dst_port_max": 1523,
        "dst_port_min": 1521,
        "dst_type": "CIDR_BLOCK",
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "TCP",
        "src": null,
        "src_port_max": 22,
        "src_port_min": 21,
        "src_type": null,
        "stateless": null
      },
      {
        "_position": 6,
        "_source": "icmp/3.4",
        "_type": "sl_icmp",
        "description": null,
        "dst": "0.0.0.0/0",
        "dst_port_max": null,
        "dst_port_min": null,
        "dst_type": "CIDR_BLOCK",
        "icmp_code": 4,
        "icmp_type": 3,
        "protocol": "ICMP",
        "src": null,
        "src_port_max": null,
        "src_port_min": null,
        "src_type": null,
        "stateless": null
      },
      {
        "_position": 7,
        "_source": "icmp/8",
        "_type": "sl_icmp",
        "description": null,
        "dst": "0.0.0.0/0",
        "dst_port_max": null,
        "dst_port_min": null,
        "dst_type": "CIDR_BLOCK",
        "icmp_code": null,
        "icmp_type": 8,
        "protocol": "ICMP",
        "src": null,
        "src_port_max": null,
        "src_port_min": null,
        "src_type": null,
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
        "dst": "all_services",
        "dst_port_max": null,
        "dst_port_min": null,
        "dst_type": "SERVICE_CIDR_BLOCK",
        "icmp_code": null,
        "icmp_type": 8,
        "protocol": "ICMP",
        "src": null,
        "src_port_max": null,
        "src_port_min": null,
        "src_type": null,
        "stateless": null
      },
      {
        "_position": 1,
        "_source": "icmp/8",
        "_type": "sl_icmp",
        "description": null,
        "dst": null,
        "dst_port_max": null,
        "dst_port_min": null,
        "dst_type": null,
        "icmp_code": null,
        "icmp_type": 8,
        "protocol": "ICMP",
        "src": "0.0.0.0/0",
        "src_port_max": null,
        "src_port_min": null,
        "src_type": "CIDR_BLOCK",
        "stateless": null
      },
      {
        "_position": 2,
        "_source": "icmp/8",
        "_type": "sl_icmp",
        "description": null,
        "dst": null,
        "dst_port_max": null,
        "dst_port_min": null,
        "dst_type": null,
        "icmp_code": null,
        "icmp_type": 8,
        "protocol": "ICMP",
        "src": "all_services",
        "src_port_max": null,
        "src_port_min": null,
        "src_type": "SERVICE_CIDR_BLOCK",
        "stateless": null
      }
    ]
  }
}
'

export TF_VAR_sl_key=test1
output_name=sl_cislz_egress_key
# parameter is expected json
# take it executing:
# expect_tf_answer sl_egress ''; show_received_json
expect_tf_answer sl_egress '
[
  {
    "_position": 0,
    "_source": "tcp/22",
    "_type": "sl_dst_only",
    "description": "ssh for everybody!",
    "dst": "0.0.0.0/0",
    "dst_port_max": 22,
    "dst_port_min": 22,
    "dst_type": "CIDR_BLOCK",
    "icmp_code": null,
    "icmp_type": null,
    "protocol": "TCP",
    "src": null,
    "src_port_max": null,
    "src_port_min": null,
    "src_type": null,
    "stateless": "true"
  },
  {
    "_position": 1,
    "_source": "tcp/8080",
    "_type": "sl_dst_only",
    "description": null,
    "dst": "0.0.0.0/0",
    "dst_port_max": 8080,
    "dst_port_min": 8080,
    "dst_type": "CIDR_BLOCK",
    "icmp_code": null,
    "icmp_type": null,
    "protocol": "TCP",
    "src": null,
    "src_port_max": null,
    "src_port_min": null,
    "src_type": null,
    "stateless": null
  },
  {
    "_position": 2,
    "_source": "tcp/80-90",
    "_type": "sl_dst_only",
    "description": null,
    "dst": "0.0.0.0/0",
    "dst_port_max": 90,
    "dst_port_min": 80,
    "dst_type": "CIDR_BLOCK",
    "icmp_code": null,
    "icmp_type": null,
    "protocol": "TCP",
    "src": null,
    "src_port_max": null,
    "src_port_min": null,
    "src_type": null,
    "stateless": null
  },
  {
    "_position": 3,
    "_source": "tcp/:1521-1523",
    "_type": "sl_src_dst",
    "description": null,
    "dst": "0.0.0.0/0",
    "dst_port_max": 1523,
    "dst_port_min": 1521,
    "dst_type": "CIDR_BLOCK",
    "icmp_code": null,
    "icmp_type": null,
    "protocol": "TCP",
    "src": null,
    "src_port_max": null,
    "src_port_min": null,
    "src_type": null,
    "stateless": null
  },
  {
    "_position": 4,
    "_source": "TcP/22:",
    "_type": "sl_src_dst",
    "description": null,
    "dst": "0.0.0.0/0",
    "dst_port_max": null,
    "dst_port_min": null,
    "dst_type": "CIDR_BLOCK",
    "icmp_code": null,
    "icmp_type": null,
    "protocol": "TCP",
    "src": null,
    "src_port_max": 22,
    "src_port_min": 22,
    "src_type": null,
    "stateless": null
  },
  {
    "_position": 5,
    "_source": "TcP/21-22:1521-1523",
    "_type": "sl_src_dst",
    "description": null,
    "dst": "0.0.0.0/0",
    "dst_port_max": 1523,
    "dst_port_min": 1521,
    "dst_type": "CIDR_BLOCK",
    "icmp_code": null,
    "icmp_type": null,
    "protocol": "TCP",
    "src": null,
    "src_port_max": 22,
    "src_port_min": 21,
    "src_type": null,
    "stateless": null
  },
  {
    "_position": 6,
    "_source": "icmp/3.4",
    "_type": "sl_icmp",
    "description": null,
    "dst": "0.0.0.0/0",
    "dst_port_max": null,
    "dst_port_min": null,
    "dst_type": "CIDR_BLOCK",
    "icmp_code": 4,
    "icmp_type": 3,
    "protocol": "ICMP",
    "src": null,
    "src_port_max": null,
    "src_port_min": null,
    "src_type": null,
    "stateless": null
  },
  {
    "_position": 7,
    "_source": "icmp/8",
    "_type": "sl_icmp",
    "description": null,
    "dst": "0.0.0.0/0",
    "dst_port_max": null,
    "dst_port_min": null,
    "dst_type": "CIDR_BLOCK",
    "icmp_code": null,
    "icmp_type": 8,
    "protocol": "ICMP",
    "src": null,
    "src_port_max": null,
    "src_port_min": null,
    "src_type": null,
    "stateless": null
  }
]
'

export TF_VAR_sl_key=test2
expect_mode=json
output_name=sl_cislz_ingress_key
# parameter is expected json
# take it executing:
# expect_tf_answer sl_ingress ''; show_received_json
expect_tf_answer sl_ingress '
[
  {
    "_position": 1,
    "_source": "icmp/8",
    "_type": "sl_icmp",
    "description": null,
    "dst": null,
    "dst_port_max": null,
    "dst_port_min": null,
    "dst_type": null,
    "icmp_code": null,
    "icmp_type": 8,
    "protocol": "ICMP",
    "src": "0.0.0.0/0",
    "src_port_max": null,
    "src_port_min": null,
    "src_type": "CIDR_BLOCK",
    "stateless": null
  },
  {
    "_position": 2,
    "_source": "icmp/8",
    "_type": "sl_icmp",
    "description": null,
    "dst": null,
    "dst_port_max": null,
    "dst_port_min": null,
    "dst_type": null,
    "icmp_code": null,
    "icmp_type": 8,
    "protocol": "ICMP",
    "src": "all_services",
    "src_port_max": null,
    "src_port_min": null,
    "src_type": "SERVICE_CIDR_BLOCK",
    "stateless": null
  }
]
'

unset TF_VAR_sl_lex
unset TF_VAR_sl_lang
unset TF_VAR_sl_map
unset TF_VAR_sl_key
unset TF_VAR_data_format
unset output_name
unset expect_mode

