import threefoldtech.vgrid.gridproxy

fn do() ! {
	mut gp_client := gridproxy.get(.test, true)!
	farms := gp_client.get_farms()!
	// println(farms)

	// get gateway list
	gateways := gp_client.get_gateways()!
	// get contract list
	contracts := gp_client.get_contracts()!
	// get grid stats
	stats := gp_client.get_stats()!
	// println(stats)
	// get twins
	twins := gp_client.get_twins()!

	// get node list
	nodes := gp_client.get_nodes(dedicated: true, free_ips: u64(1))!
	println(nodes)

	// amazing documentation on https://github.com/threefoldtech/vgrid/blob/development/gridproxy/README.md
}

fn main() {
	do() or { panic(err) }
}
