import crystallib.twinclient as tw


fn main() {
	mut transport := tw.RmbTwinClient{}
	transport.init()?
	mut grid := tw.grid_client(transport)?
	grid.algorand_list()?
}
