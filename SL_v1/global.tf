# general regexp patterns
locals {
  regexp_cidr = "([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\/[0-9]{1,3})"
  regexp_label = "([\\w\\.\\/]+)"
  regexp_ip_ports_dst = "(?i)(tcp|udp)\\/([0-9]*)-?([0-9]*)"
  regexp_ip_ports_full = format("%s:%s",local.regexp_ip_ports_dst,"([0-9]*)-?([0-9]*)")
  regexp_icmp_tc = "(?i)icmp\\/([0-9]*).?([0-9]*)"
  regexp_state = "(>{1,2})"
  regexp_stateless = "(stateless)*"
  regexp_comment = "(?:\\/\\*\\s*)?(?:([\\w !,]*))(?:\\*\\/)"
  regexp_comment_option = "(?:\\/\\*\\s*)?(?:([\\w !,]*))(?:\\*\\/)?"
  regexp_eol = "$"
}

# critical error indicator record
# will be chosen when interim processing does not include some of input records.
locals {
  sl_critical_error = {
    "error" = {
            _position   = -1
            _format = "error"
            description = "Critical processing error. Record does not processed by any routine."
            protocol = null
            src      = null
            dst = null
            stateless = null
        } 
    } 
}

# terraform provider protocol codes
locals {
  protocol2code = {
    "TCP" = 6
    "UDP" = 17
    "ICMP" = 1
  }
}