module ipaddress

import regex
import os
import freeflowuniverse.crystallib.process

pub struct IPAddress {
pub:
	addr string
	// e.g. 24, default not specified
	mask int
	port int
	cat  IpAddressType = .ipv4
}

pub enum IpAddressType {
	ipv4
	ipv6
}

// TODO: implementation not correct !!!

// format: localhost:7777
// format: 192.168.6.6:7777
// format: 192.168.6.6
// format: any ipv6 addr
// format: localhost:7777/24
// format ipv6: [x:x:x:x:x:x:x:x]:p TODO: implement
// format ipv6: x:x:x:x:x:x:x:x
// format ipv6: x::x/96
pub fn ipaddress_new(addr_string string) ?IPAddress {
	mut cat := IpAddressType.ipv4
	mut addr := addr_string
	mut port := ''
	mut mask := 0

	if addr_string.starts_with('localhost') {
		addr = addr_string.replace('localhost', '127.0.0.1')
	}

	if addr.contains("/") {
		splitted := addr.split(addr)
		if splitted.len == 2 {
			mask = splitted[1].int()
			addr = splitted[0]
		} else {
			return error('syntax error in ipaddr: $addr, should only have one /')
		}
	}

	if addr.contains("::") && addr.count('::') == 1 {
		cat = IpAddressType.ipv6
		s := addr.split('::')
		addr, port = s[0], s[1]
	} else if addr.contains(":") && addr.count(':') == 1 {
		cat = IpAddressType.ipv4
		s := addr.split(':')
		addr, port = s[0], s[1]
	} else if addr.contains(":") && addr.count(':') > 1 {
		cat = IpAddressType.ipv6
	} else if addr.contains(".") && addr.count('.') == 3 {
		cat = IpAddressType.ipv4
	} else {
		return error('Invalid Ip address string')
	}

	mut ip := IPAddress{
		addr: addr.trim_space()
		port: port.int()
		cat: cat
		mask: mask
	}

	ip.check()?

	return ip
}

pub struct PingArgs {
pub mut:
	retry   int
	timeout int
}

// PingArgs: retry & timeout
// retry default 1
// timeout default 1000 (msec)
pub fn (mut ipaddr IPAddress) ping(args_ PingArgs) bool {
	mut args := args_
	if args.retry == 0 {
		args.retry = 1
	}
	if args.timeout == 0 {
		args.timeout = 1000
	}

	mut timeout := int(args.timeout / 1000)
	if timeout < 1 {
		timeout = 1
	}

	mut cmd := ''
	if ipaddr.cat == IpAddressType.ipv4 {
		cmd = 'ping -c 1 -W $args.timeout $ipaddr.addr'
	} else {
		if process.is_osx() {
			cmd = 'ping6 -c 1 -i $timeout $ipaddr.addr'
		} else {
			cmd = 'ping -6 -c 1 -W $args.timeout $ipaddr.addr'
		}
	}
	for _ in 0 .. args.retry {
		println(cmd)
		res := os.execute(cmd)
		if res.exit_code > 0 {
			continue
		}
		return true
	}
	return false
}

// check if ipaddress is well formed
pub fn (mut ipaddr IPAddress) check() ? {
	mut query := r''
	if ipaddr.cat == IpAddressType.ipv4 {
		query = r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
	} else {
		query = r'(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))'
	}
	mut re := regex.regex_opt(query) or { panic(err) }

	start, _ := re.match_string(ipaddr.addr)

	if start < 0 {
		return error('Invalid Ip address string. $ipaddr')
	}
}

fn (mut ipaddr IPAddress) address() ?string {
	if ipaddr.cat == IpAddressType.ipv4 {
		if ipaddr.port > 0 {
			if ipaddr.mask > 0 {
				return error('cannot have mask when port specified')
			}
			return '$ipaddr.addr:$ipaddr.port'
		} else {
			if ipaddr.mask > 0 {
				return '$ipaddr.addr/$ipaddr.mask'
			} else {
				return '$ipaddr.addr'
			}
		}
	} else {
		if ipaddr.port > 0 {
			if ipaddr.mask > 0 {
				return error('cannot have mask when port specified')
			}
			return '[$ipaddr.addr]:$ipaddr.port'
		} else {
			if ipaddr.mask > 0 {
				return '$ipaddr.addr/$ipaddr.mask'
			} else {
				return '$ipaddr.addr'
			}
		}
	}
}
