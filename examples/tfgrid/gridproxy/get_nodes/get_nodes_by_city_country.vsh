#!/usr/bin/env -S v -n -w -enable-globals -cg run

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.ui.console

mut myfilter := gridproxy.nodefilter()!

myfilter.city = 'Rio de Janeiro'
myfilter.country = 'Brazil'
myfilter.status = 'up'

mut gp_client := gridproxy.new(net:.main, cache:false)!
mynodes := gp_client.get_nodes(myfilter)!

console.print_debug("${mynodes}")
