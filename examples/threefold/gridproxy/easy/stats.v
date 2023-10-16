import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.gridproxy.model

fn main(){
	mut gp_client := gridproxy.get(.dev,true)!
	
	grid_online_stats := gp_client.get_stats(status: .online)!
	println(grid_online_stats)

	grid_all_stats := gp_client.get_stats(status: .all)!
	// println(grid_all_stats)
}