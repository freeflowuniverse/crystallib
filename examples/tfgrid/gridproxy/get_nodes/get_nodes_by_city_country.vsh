#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.threefold.gridproxy { TFGridNet }
import freeflowuniverse.crystallib.threefold.gridproxy.model { Node, NodeFilter }
import log
import os

fn main() {
	mut logger := log.Log{
		level: .debug
	}

	// Default value used in intializing the resources
	mut nodes_filter := NodeFilter{}

	if '--help' in os.args {
		println('This script to get nodes by city or country or both \n
		--city		name of the city  (optional) \n
		--country	name of the country (optional) \n
		--network	one of (dev, test, qa, main)  (optional) (default to `test`) \n
		--max-count	maximum number of nodes to be selected (optional) (default to 0 which means no limit) \n
		--cache		enable cache  (optional) (default to false)')
		return
	}

	if '--city' in os.args {
		index_val := os.args.index('--city')
		nodes_filter.city = os.args[index_val + 1].to_lower().title() // ensure that the city is in title case, which is the case in the database.
	}

	if '--country' in os.args {
		mut index_val := os.args.index('--country')
		nodes_filter.country = os.args[index_val + 1].to_lower().title() // ensure that the country is in title case, which is the case in the database.
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
	nodes_iter := gp_client.get_nodes_iterator(nodes_filter) /*
	or {
		logger.info('got an error while getting nodes')
		logger.info('error message : ${err.msg()}')
		logger.info('error code : ${err.code()}')
		return
	}*/

	mut nodes_by_city_country := []Node{}
	outer: for nodes in nodes_iter {
		for node in nodes {
			nodes_by_city_country << node
			if max_count > 0 && nodes_by_city_country.len == max_count {
				break outer
			}
		}
	}
	logger.info('found ${nodes_by_city_country.len} nodes on ${net.to_upper()} in country: ${nodes_filter.country} and city: ${nodes_filter.city}')
	logger.info('---------------------------------------')
	logger.info('${nodes_by_city_country}')
}
