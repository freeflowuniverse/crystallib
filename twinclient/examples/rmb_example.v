import freeflowuniverse.crystallib.twinclient as tw


fn main() {
	mut transport := tw.RmbTwinClient{}
	transport.init([143], 5, 5)?
	mut grid := tw.grid_client(transport)?
	println(grid.algorand_list()?)
}
