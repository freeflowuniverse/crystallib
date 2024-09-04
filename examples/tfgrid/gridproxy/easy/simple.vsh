#!/usr/bin/env -S v -n -w -enable-globals -cg run

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.ui.console

mut gp_client := gridproxy.new(net:.test, cache:true)!

// get farm list
farms := gp_client.get_farms()!
console.print_debug('${farms}')

// get gateway list
gateways := gp_client.get_gateways()!
console.print_debug('${gateways}')

// get contract list
contracts := gp_client.get_contracts()!
console.print_debug('${contracts}')

// get grid stats
stats := gp_client.get_stats()!
console.print_debug('${stats}')

// get twin list
twins := gp_client.get_twins()!
console.print_debug('${twins}')

// get node list
mut nodefilter := gridproxy.nodefilter()!
nodefilter.dedicated = true
nodefilter.free_ips = u64(1)
nodefilter.status = 'up'
nodes := gp_client.get_nodes(nodefilter)!
console.print_debug('${nodes}')

