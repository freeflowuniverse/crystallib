import freeflowuniverse.crystallib.twinclient as tw

fn main2() {
	mut transport := tw.RmbTwinClient{}
	transport.init([143], 5, 5)!
	mut grid := tw.grid_client(transport)!
	println(grid.algorand_list()!)
	created := grid.algorand_init('alice', 'below library secret olympic clutch debris radio easy humble punch sock ocean axis lock consider hope can torch table old orbit address quality abandon disagree')!
	println(created)
	// grid.algorand_assets_by_address(created.address)!
	grid.algorand_delete('alice')!
}
