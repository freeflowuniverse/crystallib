module tffarm
import despiegk.crystallib.ipaddr

pub struct Node {
pub mut:
	//id as given by threefold grid, visible when boot
	node_id int
	//optional, for farmer to identify node
	id string
	//optional, for farmer to remember more info
	description string
	//optional, again for farmer to remember
	location string
	interfaces []Interface
	//e.g. IPMI device
	mgmt []ManagementDevice
}

pub struct Interface {
pub mut:
	macaddr string
	//list of network range names, needs to correspond with name of network range (4 or 6)
	//multiple network interfaces can be in same range
	//is optional, if not specified then its private range and through NAT node can go out
	network_ranges []string
	//optional, for farmer if relevant
	description string	
}

// check if well formed
pub fn (mut node Node) check(mut farm TFFarm) ? {
	//TODO: check interface exists in farm
	//TODO: check macaddress has right format of interface

}
