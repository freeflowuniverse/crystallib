module tffarm

//public routable network range for ipv4
pub struct NetworkRange {
pub mut:
	//name needs to be unique over all ranges
	name string
	// format ipv6: ...
	// format ipv4: 212.3.247.1	
	//start of range
	address_start string
	//end of range
	address_end string
	//how many mbit is connection to internet for this range
	capacity_mbit int
	//relevant information about this network range
	description string
	cat  IpAddressType = IpAddressType.ipv4
	//if yes means the network goes out over multiple links to provider
	network_redundant bool

}

pub enum IpAddressType {
	ipv4
	ipv6
}


// check if ipaddress is well formed
pub fn (mut ipaddr NetworkRange) check() ? {
	mut query := r''
	if ipaddr.cat == IpAddressType.ipv4 {
		query = r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
	} else {
		query = r'(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))'
	}
	mut re := regex.regex_opt(query) or { panic(err) }

	start, _ := re.match_string(ipaddr.addr)

	if start < 0 {
		return error('Invalid range string. $ipaddr')
	}
}
