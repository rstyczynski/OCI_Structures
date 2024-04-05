#!/bin/bash

source ../lib/tf_tests.sh



echo '============================='
echo '====== lex mode'
echo '============================='

export TF_VAR_data_format="sl_lex"

export TF_VAR_sl_lex='
 {
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
'
expect_mode=json
output_name=sl_lex
export TF_VAR_sl_key=demo1
# parameter is expected json
# take it executing:
# expect_tf_answer sl_lex ''; show_received_json
expect_tf_answer sl_lex '
{
  "demo1": {
    "rules": [
      {
        "_format": "regexp_egress",
        "_position": "0",
        "_src": "TcP/21-22:1521-1523 >> on_premises /* DB for some of you */",
        "description": "DB for some of you ",
        "dst": "on_premises",
        "protocol": "TcP/21-22:1521-1523",
        "src": null,
        "stateless": "true"
      },
      {
        "_format": "regexp_ingress",
        "_position": "1",
        "_src": "internet      >> uDP/20000-30000:80-90 /* HTTP over UDP for some of you */",
        "description": "HTTP over UDP for some of you ",
        "dst": null,
        "protocol": "uDP/20000-30000:80-90",
        "src": "internet",
        "stateless": "true"
      },
      {
        "_format": "regexp_egress",
        "_position": "2",
        "_src": "tcp/:1521-1523 > 0.0.0.0/0",
        "description": "",
        "dst": "0.0.0.0/0",
        "protocol": "tcp/:1521-1523",
        "src": null,
        "stateless": "false"
      },
      {
        "_format": "regexp_ingress_dst",
        "_position": "3",
        "_src": "0.0.0.0/0      >> uDP/22-23 /* strange ingress udp */",
        "description": "strange ingress udp ",
        "dst": null,
        "protocol": "uDP/22-23",
        "src": "0.0.0.0/0",
        "stateless": "true"
      },
      {
        "_format": "regexp_egress_dst",
        "_position": "4",
        "_src": "tcp/22         >> 0.0.0.0/0 /* ssh for all! */",
        "description": "ssh for all! ",
        "dst": "0.0.0.0/0",
        "protocol": "tcp/22",
        "src": null,
        "stateless": "true"
      },
      {
        "_format": "regexp_ingress",
        "_position": "5",
        "_src": "0.0.0.0/0      > TcP/21-22:1521-1523 /* DB for everyone */",
        "description": "DB for everyone ",
        "dst": null,
        "protocol": "TcP/21-22:1521-1523",
        "src": "0.0.0.0/0",
        "stateless": "false"
      },
      {
        "_format": "regexp_egress_dst",
        "_position": "6",
        "_src": "tcp/80-90      >  0.0.0.0/0 /* stateless extended http */",
        "description": "stateless extended http ",
        "dst": "0.0.0.0/0",
        "protocol": "tcp/80-90",
        "src": null,
        "stateless": "false"
      },
      {
        "_format": "regexp_egress",
        "_position": "7",
        "_src": "tcp/:22         >> 0.0.0.0/0 /* ssh for all! */",
        "description": "ssh for all! ",
        "dst": "0.0.0.0/0",
        "protocol": "tcp/:22",
        "src": null,
        "stateless": "true"
      },
      {
        "_format": "regexp_ingress_dst",
        "_position": "8",
        "_src": "0.0.0.0/0      >> uDP/222-223",
        "description": null,
        "dst": null,
        "protocol": "uDP/222-223",
        "src": "0.0.0.0/0",
        "stateless": "true"
      }
    ]
  },
  "demo2": {
    "rules": [
      {
        "_format": "regexp_icmp_egress_cmt",
        "_position": "0",
        "_src": "icmp/3.4       >> 0.0.0.0/0 /* egress icmp type 3, code 4 */",
        "description": "egress icmp type 3, code 4 ",
        "dst": "0.0.0.0/0",
        "protocol": "icmp/3.4",
        "src": null
      },
      {
        "_format": "regexp_icmp_ingress",
        "_position": "1",
        "_src": "0.0.0.0/0      >> icmp/8",
        "description": null,
        "dst": null,
        "protocol": "icmp/8.",
        "src": "0.0.0.0/0"
      },
      {
        "_format": "regexp_icmp_ingress_cmt",
        "_position": "2",
        "_src": "0.0.0.0/0      >> icmp/1. /* icmp type 1 */",
        "description": "icmp type 1 ",
        "dst": null,
        "protocol": "icmp/1.",
        "src": "0.0.0.0/0"
      },
      {
        "_format": "regexp_icmp_egress",
        "_position": "3",
        "_src": "icmp/3.        > 0.0.0.0/0",
        "description": null,
        "dst": "0.0.0.0/0",
        "protocol": "icmp/3.",
        "src": null
      },
      {
        "_format": "regexp_icmp_ingress",
        "_position": "4",
        "_src": "0.0.0.0/0      > icmp/8.1",
        "description": null,
        "dst": null,
        "protocol": "icmp/8.1",
        "src": "0.0.0.0/0"
      }
    ]
  }
}
'

expect_mode=json
output_name=sl
export TF_VAR_sl_key=demo1
# parameter is expected json
# take it executing:
# expect_tf_answer sl_lex ''; show_received_json
expect_tf_answer sl '
{
  "demo1": {
    "rules": [
      {
        "_position": 0,
        "_source": "TcP/21-22:1521-1523",
        "_type": "sl_src_dst",
        "description": "DB for some of you ",
        "dst": "192.0.0.0/8",
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
        "stateless": "true"
      },
      {
        "_position": 1,
        "_source": "uDP/20000-30000:80-90",
        "_type": "sl_src_dst",
        "description": "HTTP over UDP for some of you ",
        "dst": null,
        "dst_port_max": 90,
        "dst_port_min": 80,
        "dst_type": null,
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "UDP",
        "src": "0.0.0.0/0",
        "src_port_max": 30000,
        "src_port_min": 20000,
        "src_type": "CIDR_BLOCK",
        "stateless": "true"
      },
      {
        "_position": 2,
        "_source": "tcp/:1521-1523",
        "_type": "sl_src_dst",
        "description": "",
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
        "stateless": "false"
      },
      {
        "_position": 3,
        "_source": "uDP/22-23",
        "_type": "sl_dst_only",
        "description": "strange ingress udp ",
        "dst": null,
        "dst_port_max": 23,
        "dst_port_min": 22,
        "dst_type": null,
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "UDP",
        "src": "0.0.0.0/0",
        "src_port_max": null,
        "src_port_min": null,
        "src_type": "CIDR_BLOCK",
        "stateless": "true"
      },
      {
        "_position": 4,
        "_source": "tcp/22",
        "_type": "sl_dst_only",
        "description": "ssh for all! ",
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
        "_position": 5,
        "_source": "TcP/21-22:1521-1523",
        "_type": "sl_src_dst",
        "description": "DB for everyone ",
        "dst": null,
        "dst_port_max": 1523,
        "dst_port_min": 1521,
        "dst_type": null,
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "TCP",
        "src": "0.0.0.0/0",
        "src_port_max": 22,
        "src_port_min": 21,
        "src_type": "CIDR_BLOCK",
        "stateless": "false"
      },
      {
        "_position": 6,
        "_source": "tcp/80-90",
        "_type": "sl_dst_only",
        "description": "stateless extended http ",
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
        "stateless": "false"
      },
      {
        "_position": 7,
        "_source": "tcp/:22",
        "_type": "sl_src_dst",
        "description": "ssh for all! ",
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
        "_position": 8,
        "_source": "uDP/222-223",
        "_type": "sl_dst_only",
        "description": null,
        "dst": null,
        "dst_port_max": 223,
        "dst_port_min": 222,
        "dst_type": null,
        "icmp_code": null,
        "icmp_type": null,
        "protocol": "UDP",
        "src": "0.0.0.0/0",
        "src_port_max": null,
        "src_port_min": null,
        "src_type": "CIDR_BLOCK",
        "stateless": "true"
      }
    ]
  },
  "demo2": {
    "rules": [
      {
        "_position": 0,
        "_source": "icmp/3.4",
        "_type": "sl_icmp",
        "description": "egress icmp type 3, code 4 ",
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
        "_position": 1,
        "_source": "icmp/8.",
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
        "_source": "icmp/1.",
        "_type": "sl_icmp",
        "description": "icmp type 1 ",
        "dst": null,
        "dst_port_max": null,
        "dst_port_min": null,
        "dst_type": null,
        "icmp_code": null,
        "icmp_type": 1,
        "protocol": "ICMP",
        "src": "0.0.0.0/0",
        "src_port_max": null,
        "src_port_min": null,
        "src_type": "CIDR_BLOCK",
        "stateless": null
      },
      {
        "_position": 3,
        "_source": "icmp/3.",
        "_type": "sl_icmp",
        "description": null,
        "dst": "0.0.0.0/0",
        "dst_port_max": null,
        "dst_port_min": null,
        "dst_type": "CIDR_BLOCK",
        "icmp_code": null,
        "icmp_type": 3,
        "protocol": "ICMP",
        "src": null,
        "src_port_max": null,
        "src_port_min": null,
        "src_type": null,
        "stateless": null
      },
      {
        "_position": 4,
        "_source": "icmp/8.1",
        "_type": "sl_icmp",
        "description": null,
        "dst": null,
        "dst_port_max": null,
        "dst_port_min": null,
        "dst_type": null,
        "icmp_code": 1,
        "icmp_type": 8,
        "protocol": "ICMP",
        "src": "0.0.0.0/0",
        "src_port_max": null,
        "src_port_min": null,
        "src_type": "CIDR_BLOCK",
        "stateless": null
      }
    ]
  }
}
'


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
output_name=sl
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
output_name=sl
export TF_VAR_sl_key=test1
# parameter is expected json
# take it executing:
# expect_tf_answer sl ''; show_received_json
expect_tf_answer sl '{
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
output_name=sl_egress_key
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
    "src_port_max": null,
    "src_port_min": null,
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
    "src_port_max": null,
    "src_port_min": null,
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
    "src_port_max": null,
    "src_port_min": null,
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
    "src_port_max": null,
    "src_port_min": null,
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
    "src_port_max": 22,
    "src_port_min": 22,
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
    "src_port_max": 22,
    "src_port_min": 21,
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
    "src_port_max": null,
    "src_port_min": null,
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
    "src_port_max": null,
    "src_port_min": null,
    "stateless": null
  }
]
'

export TF_VAR_sl_key=test2
expect_mode=json
output_name=sl_ingress_key
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
unset TF_VAR_sl_map
unset TF_VAR_sl_key
unset TF_VAR_data_format
unset output_name
unset expect_mode

