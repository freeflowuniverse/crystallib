import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.gridproxy.model

fn main() {
	// init gridproxy client on devnet with redis cash
	mut gp_client := gridproxy.get(.dev, true)!

	mut node_filter := model.NodeFilter{}

	node_filter.status = 'up'
	// node_filter.country = "egypt"
	// node_filter.free_ips = u64(4)
	// node_filter.dedicated= true
	// node_filter.free_sru = u64(9000) //bytes

	nodes := gp_client.get_nodes(node_filter)!
	// println(nodes)

	node := nodes[0] or { gp_client.get_node_by_id(11)! }
	node_id := node.node_id

	// get node available resources
	node_available_resources := node.calc_available_resources()
	// println(node_available_resources)

	// get node status
	node_stats := gp_client.get_node_stats_by_id(node_id)!
	// println(node_stats)

	// using resource filter

	resources := model.ResourceFilter{
		free_sru_gb: 1 //gb
		free_hru_gb:0
		free_mru_gb: 0
		free_ips:0
	}

	nodes_has_resources := gp_client.get_nodes_has_resources(resources)

	// this returns all nodes that have the provided resources
	all_nodes_with_resources := nodes_has_resources.get_func()!
	// println(all_nodes_with_resources)

	// you can maintain the returned filter
	mut has_resources_filter := nodes_has_resources.filter
	// to get the available nodes (Up), that have the provided resources
	has_resources_filter.status ="up"
	available_nodes :=  gp_client.get_nodes(has_resources_filter)!
	println(available_nodes)

	// node iterator

	max_page_iteration := u64(5) // set maximum pages to iterate on

	mut node_iterator := gp_client.get_nodes_iterator(status: 'up')
	mut iterator_available_node := []model.Node{}
	for {
		if node_iterator.filter.page is u64 && node_iterator.filter.page >= max_page_iteration {
			break
		}

		iterator_nodes := node_iterator.next()
		if iterator_nodes != none {
			iterator_available_node << iterator_nodes
		} else {
			break //if the page is empty the next function will return none
		}
	}
	// println(iterator_available_node)
}
