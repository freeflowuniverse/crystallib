
module deploy
import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.gridproxy.model as gridproxy_models



pub fn nodefilter(specs VMRequirements)! []gridproxy_models.Node {
	net := resolve_network()!
	mut myfilter := gridproxy.nodefilter()!

	myfilter.free_mru = u64(specs.memory ) * 1024 * 1024 * 1024
	myfilter.free_sru = u64(specs.cpu)
	myfilter.ipv4 = specs.public_ip4
	myfilter.ipv6 = specs.public_ip6
	myfilter.status = "up"
	myfilter.healthy = true

	mut gp_client := gridproxy.new(net:net, cache:true)!
	nodes := gp_client.get_nodes(myfilter)!
	return nodes
}
