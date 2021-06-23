module tffarm

fn test_main() {
	mut farm := TFFarm{}

	range1 := NetworkRange{
		name:"net1",
		address_start:"212.123.3.10",
		address_end:"212.123.3.20",
		capacity_mbit:10,
		description: "my description",
		cat: IpAddressType.ipv4,
		network_redundant: false
	}

	range2 := NetworkRange{
		name:"net6",
		address_start:"fe80::80f4:1fff:fed6:f802",
		address_end:"fe80::80f4:1fff:fed7:fffe",
		capacity_mbit:100,
		description: "faster link",
		cat: IpAddressType.ipv6,
		network_redundant: true
	}


	farm.name = "myfarm_ghent"
	farm.description = "this is a test farm"

	//add the ranges
	farm.network_ranges << range1
	farm.network_ranges << range2

	farm.location_type = LocationType.datacenter_commercial
	farm.location_description = "this is a super location, next to airport Eindhoven"
	farm.farming_wallet = "aabbccddeeff"

	node1 := Node{
		node_id: 100,
		id: "a4vf",
		description: "a descr",
		location: "rack10_a_22"
	}

	node1.interfaces << Interface{macaddr:"aabbccddeeff",network_ranges:["net6"]}
	node1.interfaces << Interface{macaddr:"aabbccddeeee",network_ranges:["net1","net6"]}

	node2 := Node{
		node_id: 101,
		id: "a4ee",
		description: "a descr 2",
		location: "rack10_a_24"
	}

	node2.interfaces << Interface{macaddr:"aabbccddeeaa",network_ranges:["net6"]}

	farm.nodes  << node1
	farm.nodes  << node2

	assert farm.check()

	println(farm)

	//saves info as relevant for farmer, can use this to e.g. manage IPMI
	farm.save("/tmp/farms_private",false)
	//info which will go to git, does not have info for IPMI
	farm.save("/tmp/farms_public",true)

	//PHASE 2: will work with reliable message bus to listen for requests to change
	// this runs the farm manager on site, uses planetary network
	// farm.manage()

	//just to see output
	panic("s")
}
