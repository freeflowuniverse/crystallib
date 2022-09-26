import crystallib.twinclient as tw


fn main() {
	mut transport := tw.RmbTwinClient{}
	rmb := transport.init()?
	println(rmb.message)
	// mut grid := tw.grid_client(transport)?
	// grid.algorand_list()?
}
