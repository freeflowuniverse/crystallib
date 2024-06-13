#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.gridproxy.model
import log

fn get_farms_example() ! {
	mut logger := log.Log{
		level: .debug
	}
	mut gp_client := gridproxy.get(.dev, true)!
	filter := model.FarmFilter{}
	farms := gp_client.get_farms(filter)!
	logger.info('${farms}')
}

fn get_farm_by_name_example(farm_name string) ! {
	mut logger := log.Log{
		level: .debug
	}
	mut gp_client := gridproxy.get(.dev, true)!
	farms := gp_client.get_farms(name: farm_name)!
	logger.info('${farms}')
}

fn get_farms_iterator_example() ! {
	mut logger := log.Log{
		level: .debug
	}
	mut gp_client := gridproxy.get(.dev, true)!

	max_page_iteration := u64(2) // set maximum pages to iterate on

	mut farm_iterator := gp_client.get_farms_iterator(country: 'egypt', node_status: 'up')
	mut iterator_available_farms := []model.Farm{}
	for {
		if farm_iterator.filter.page is u64 && farm_iterator.filter.page >= max_page_iteration {
			break
		}

		iterator_farms := farm_iterator.next()
		if iterator_farms != none {
			iterator_available_farms << iterator_farms
		} else {
			break // if the page is empty the next function will return none
		}
	}
	logger.info('${iterator_available_farms}')
}

fn main() {
	get_farms_example()!
	get_farm_by_name_example("freefarm")!
	get_farms_iterator_example()!
}