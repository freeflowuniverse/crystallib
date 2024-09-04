#!/usr/bin/env -S v -n -w -enable-globals -cg run

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.ui.console

fn get_farms_example() ! {
	mut myfilter := gridproxy.farmfilter()!

	myfilter.country = 'Egypt'
	myfilter.total_ips = u64(10)

	mut gp_client := gridproxy.new(net:.dev, cache:true)!
	myfarms := gp_client.get_farms(myfilter)!

	console.print_debug("${myfarms}")
}

fn get_farm_by_name_example(farm_name string) ! {
	mut myfilter := gridproxy.farmfilter()!

	myfilter.name = farm_name

	mut gp_client := gridproxy.new(net:.main, cache:true)!
	myfarms := gp_client.get_farms(myfilter)!

	console.print_debug("${myfarms}")
}

// fn get_farms_iterator_example() ! {
// 	mut logger := &log.Log{}
// 	logger.set_level(.debug)
// 	mut gp_client := gridproxy.get(.dev, true)!

// 	max_page_iteration := u64(2) // set maximum pages to iterate on

// 	mut farm_iterator := gp_client.get_farms_iterator(country: 'egypt', node_status: 'up')
// 	mut iterator_available_farms := []model.Farm{}
// 	for {
// 		if farm_iterator.filter.page is u64 && farm_iterator.filter.page >= max_page_iteration {
// 			break
// 		}

// 		iterator_farms := farm_iterator.next()
// 		if iterator_farms != none {
// 			iterator_available_farms << iterator_farms
// 		} else {
// 			break // if the page is empty the next function will return none
// 		}
// 	}
// 	logger.info('${iterator_available_farms}')
// }


get_farms_example()!
get_farm_by_name_example("r1_farm")!
// get_farms_iterator_example()!