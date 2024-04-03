# SL_v1
OCI terraform provider requires to use quite strange way of configuring security lists. Data structure is not intuitive, and requires a lot of writing to define access list. Landing Zone libraries try to eliminate this hassle, still keeping a lot of API overhead. One of examples are min, and max fields for tcp/udp port definition. Not bad for some of use cases, but not nice for majority of them.

This library proposes two formats:
1. One line per access rule

```
    0.0.0.0/0 >> tcp/1521-1523 /* DB access for everybody! */
```

2. Optimized protocol and port numbers

```
    description = "DB access for everybody! "
    protocol    = "tcp/1521-1523"
    source      = "0.0.0.0/0"
    destination = null
    stateless   = false
```

Both statements mean the same thing. I hope the former is just more fun to write.

You can use the latter one if you prefer, and the one-liner is always converted to the more descriptive one, which is converted to CIZ Enhanced Networking module format. 

The access list is kept in a map of objects with key representing set of access rules i.e. security list. The library produces data structure compatible with CIS Landing Zone Network Module with access code:

1. ingress

```
    local.sl_ingress["SL_NAME"].rules
```

2. egress

```
    local.sl_egress["SL_NAME"].rules
```

## Unit test test
*Note: Unit test is just a draft now, but the working one.*

Unit testing is implemented using:
* expected value is provided by tf's variable
* result is taken from tf's output

Variable is set by env's TF_VAR, and output is extracted from tf plan file.

Uni test works in two modes:
1. verify list of simple outputs a=1, b=2, etc.
2. verify single complex structure

For details look into test.sh, and try it.

```
    terraform init
    . test.sh
```

with expected answer:

```
    sl_simple OK
    sl OK
    sl_egress OK
    sl_ingress OK
```



# Change list

## 1. Implement error handling

Processing errors are reported in sl_error output. source_string contains original protocol data. Error is everything what is not:
- full pattern i.e. "(?i)(tcp|udp)\\/([0-9]*)-?([0-9]*):([0-9]*)-?([0-9]*)$"
- destination pattern i.e. "(?i)(tcp|udp)\\/([0-9]*)-?([0-9]*)$"
- icmp pattern i.e. "(?i)(icmp)\\/([0-9]+).?([0-9]*)$"

It's assumed that for each known pattern data extraction is possible, thus no other errors are reported.

```
sl_error       = {
      + demo1 = {
          + rules = [
              + {
                  + _position        = 0
                  + description      = null
                  + destination      = null
                  + destination_type = null
                  + dst_port_max     = null
                  + dst_port_min     = 0
                  + icmp_code        = null
                  + icmp_type        = null
                  + protocol         = "ERROR"
                  + source           = null
                  + source_string    = "tcp/22XX"
                  + source_type      = null
                  + src_port_max     = null
                  + src_port_min     = 0
                  + stateless        = null
                  + type             = "sl_error"
                },
            ]
        }
      + demo2 = {
          + rules = []
        }
    }
```