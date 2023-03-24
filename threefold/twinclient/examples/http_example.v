import freeflowuniverse.crystallib.twinclient as tw

fn main1() {
	mut transport := tw.HttpTwinClient{}
	transport.init('http://localhost:3000')?
	mut grid := tw.grid_client(transport)?
}
