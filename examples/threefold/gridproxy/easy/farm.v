import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.gridproxy.model

fn main(){
	mut gp_client := gridproxy.get(.dev,true)!
	mut filter := model.FarmFilter{}
	mut farms := gp_client.get_farms(filter)!
	// println(farms)

	// get farm by its name 
	filter.name = "freefarm"
	farms = gp_client.get_farms(filter)!
	println(farms)



	// farm iterator

	max_page_iteration := u64(2) // set maximum pages to iterate on

	mut farm_iterator := gp_client.get_farms_iterator(country:"egypt",node_status:"up")
	mut iterator_available_farms := []model.Farm{}
	for {
		if farm_iterator.filter.page is u64 && farm_iterator.filter.page >= max_page_iteration {
			break
		}

		iterator_farms := farm_iterator.next()
		if iterator_farms != none {
			iterator_available_farms << iterator_farms
		} else {
			break //if the page is empty the next function will return none
		}
	}
	// println(iterator_available_farms.len)
}