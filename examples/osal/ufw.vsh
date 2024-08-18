#!/usr/bin/env -S v -n -w -enable-globals run

import freeflowuniverse.crystallib.osal.ufw

println(ufw.ufw_status()!)

mut ruleset := ufw.new()

// Allow HTTP traffic from a specific IPv4 address
ruleset.allow(
	to: '80'
	from: '192.168.1.100'
)

// Allow HTTPS traffic from any IPv6 address
ruleset.allow(
	to: '443'
	ipv6: true
)

// Deny SMTP traffic from a specific IPv4 subnet
ruleset.deny(
	to: '25'
	from: '10.0.0.0/24'
)

// Deny FTP traffic from a specific IPv6 address
ruleset.deny(
	to: '21'
	from: '2001:db8::1'
	udp: true
	tcp: false
	ipv6: true
)

// Apply the ruleset
ufw.apply(ruleset) or { panic('Error applying ruleset: ${err}') }
