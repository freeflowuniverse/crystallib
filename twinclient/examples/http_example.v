import freeflowuniverse.crystallib.twinclient as tw


fn main() {
	mut transport := tw.HttpTwinClient{}
	transport.init("http://localhost:3000")?
	mut grid := tw.grid_client(transport)?
	init := grid.algorand_init("baz", "below library secret olympic clutch debris radio easy humble punch sock ocean axis lock consider hope can torch table old orbit address quality abandon disagree")?
	result := grid.algorand_assets_by_address(init.address)?

	// init := grid.algorand_init("alice","advice tribe high traffic panda river seminar clay picture bundle dignity royal fabric solution rent because visual surround act trick business metal snake abstract vapor")?
	println(result)
	// println(init)
}
