module main

import freeflowuniverse.crystallib.data.vstor

fn do() ! {
	mut vstor := vstor.new()!

	// populate 20 locations
	mut i := 0
	for i <= 20 {
		location := vstor.location_new(farmid: 'farm_${i}')!
		vstor.zdb_new(
			address: '212.3.247.${i}'
			port: 8888
			namespace: 'something'
			secret: '1234'
			location: location
		)!
	}
	println(vstor)
}

fn main() {
	do() or { panic(err) }
}
