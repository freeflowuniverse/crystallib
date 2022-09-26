import freeflowuniverse.crystallib.twinclient as tw


fn main() {
	mut transport := tw.RmbTwinClient{}
	rmb := transport.init([143], 5, 5)?
	println(rmb.message)
	// mut grid := tw.grid_client(transport)?
	// grid.algorand_list()?
}
