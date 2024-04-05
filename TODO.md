# TODO
2. Extend test.sh with error cases
7. 

100. add support for IPv6 at regexp_cidr / destination_type
110. make security_list input compatible with oci_core_security_list/egress_security_rules and oci_core_security_list/ingress_security_rules
200. ingress: 0.0.0.0/0 >> tcp/22 /* SSH for all!*/
210. egress: tcp/1521-1523 >> 0.0.0.0/0 /* Any DB for you!*/

# Notes

## 200. ingress: 0.0.0.0/0 >> tcp/22 /* SSH for all!*/

protocol    : tcp
source      : 0.0.0.0/0
destination : null
description : SSH for all!
stateless   : >> true, > false

full: /([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]{1,3})\s*>>\s*(?i)(tcp|udp)\/([0-9]*)-?([0-9]*):([0-9]*)-?([0-9]*)\s*(?:\/\*\s*)?(?:([\w !]*))(?:\*\/)?/gm

10.20.30.40/10 >> tcp/20000-20010:1521-1523 /* ssh for almost all! */
0. 10.20.30.40/10
1. tcp
3. 20000
3. 20010
4. 1521
5. 1523
6. ssh for almost all! 

src only: 

## egress

full: (?i)(tcp|udp)\/([0-9]*)-?([0-9]*):([0-9]*)-?([0-9]*)\s*(>{1,2})\s*([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]{1,3})\s*(?:\/\*\s*)?(?:([\w !]*))(?:\*\/)?

tcp/20000-20010:1521-1523 >> 10.20.30.40/10 /* ssh for almost all! */
0. tcp
1. 20000
2. 20010
3. 1521
4. 1523
5. >>
6. 10.20.30.40/10
7. ssh for almost all! 

dst only: (?i)(tcp|udp)\/([0-9]*)-?([0-9]*)\s*(>{1,2})\s*([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]{1,3})\s*(?:\/\*\s*)?(?:([\w !]*))(?:\*\/)?

tcp/1521-1523 >> 10.20.30.40/10 /* ssh for almost all! */
0. tcp
1. 1521
2. 1523
3. >>
4. 10.20.30.40/10
5. ssh for almost all! 

## 5. Change lex scheme to allow tcp to, permit tcp from...

```
>> on_premises TcP/21-22:1521-1523 /* on-prem DB for all! */"
on_premises >> TcP/21-22:1521-1523 /* Cloud DB for on-prem apps */"
```

```
stateless permit TcP/21-22:1521-1523 to on_premises /* on-prem DB for all! */"
stateless accept TcP/21-22:1521-1523 from on_premises /* Cloud DB for on-prem apps */"
```


