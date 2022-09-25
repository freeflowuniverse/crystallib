import crystallib.twinclient as tw


fn main() {
	mut transport := tw.HttpTwinClient{}
	transport.init()?
	mut grid := tw.grid_client(transport)?
	println(grid.algorand_list()?)
}
