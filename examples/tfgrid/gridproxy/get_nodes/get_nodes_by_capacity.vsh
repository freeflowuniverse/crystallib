#!/usr/bin/env -S v -n -w -enable-globals run

import freeflowuniverse.crystallib.threefold.gridproxy { TFGridNet }
import freeflowuniverse.crystallib.threefold.gridproxy.model { Node, ResourceFilter }
import log
import os

fn main() {
	mut logger := &log.Log{}
	logger.set_level(.debug)

	// Default value used in intializing the resources
	mut resources_filter := ResourceFilter{}

	if '--help' in os.args {
		println('This script to get nodes by available resources \n
		--sru		nodes selected should have a minumum value of free sru in GB (ssd resource unit) equal to this (optional) \n
		--hru		nodes selected should have a minumum value of free hru in GB (hd resource unit) equal to this (optional) \n
		--mru		nodes selected should have a minumum value of free mru in GB (memory resource unit) equal to this (optional) \n
		--ips		nodes selected should have a minumum value of ips (ips in the farm of the node) equal to this (optional) \n
		--network	one of (dev, test, qa, main) (optional) (default to `test`) \n
		--max-count	maximum number of nodes to be selected (optional) (default to 0 which means no limit) \n
		--cache		enable cache (optional) (default to false')
		return
	}

	if '--sru' in os.args {
		index_val := os.args.index('--sru')
		resources_filter.free_sru_gb = os.args[index_val + 1].u64()
	}

	if '--ips' in os.args {
		index_val := os.args.index('--ips')
		resources_filter.free_ips = os.args[index_val + 1].u64()
	}

	if '--hru' in os.args {
		index_val := os.args.index('--hru')
		resources_filter.free_hru_gb = os.args[index_val + 1].u64()
	}

	if '--mru' in os.args {
		index_val := os.args.index('--mru')
		resources_filter.free_mru_gb = os.args[index_val + 1].u64()
	}

	mut net := 'test'
	if '--network' in os.args {
		index_val := os.args.index('--network')
		net = os.args[index_val + 1]
	}

	mut max_count := 0
	if '--max-count' in os.args {
		index_val := os.args.index('--max-count')
		max_count = os.args[index_val + 1].int()
	}

	mut cache := false
	if '--cache' in os.args {
		cache = true
	}

	network := match net {
		'dev' {
			TFGridNet.dev
		}
		'test' {
			TFGridNet.test
		}
		'qa' {
			TFGridNet.qa
		}
		'main' {
			TFGridNet.main
		}
		else {
			panic('network ${net} not supported')
		}
	}
	mut gp_client := gridproxy.get(network, cache)!
	nodes_iter := gp_client.get_nodes_has_resources(resources_filter) /*
	or {
		println("got an error while getting nodes")
		println("error message : ${err.msg()}")
		println("error code : ${err.code()}")
		return
	}*/

	mut nodes_with_min_resources := []Node{}
	// itereate over all availble pages on the server and get array of nodes for each page
	outer: for nodes in nodes_iter {
		// flatten the array of nodes into a single array
		for node in nodes {
			nodes_with_min_resources << node
			if max_count > 0 && nodes_with_min_resources.len == max_count {
				break outer
			}
		}
	}
	logger.info('found ${nodes_with_min_resources.len} nodes on ${net.to_upper()} network with following min resources:\n${resources_filter}')
	if max_count > 0 {
		logger.info('Note: a limit of getting at most ${max_count} nodes was set')
	}
	logger.info('---------------------------------------')
	logger.info('${nodes_with_min_resources}')
}
