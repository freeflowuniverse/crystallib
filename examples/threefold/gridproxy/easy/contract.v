import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.gridproxy.model

fn main(){

	mut gp_client := gridproxy.get(.dev,true)!

	mut filter := model.ContractFilter{}
	filter.state = "Created"
	filter.contract_type = "node"
	filter.twin_id = u64(800)
	contracts := gp_client.get_contracts(filter)!

	println(contracts)


	// contracts iterator

	max_page_iteration := u64(2) // set maximum pages to iterate on

	mut contract_iterator := gp_client.get_contracts_iterator(contract_type:"node")
	mut iterator_available_contracts := []model.Contract{}
	for {
		if contract_iterator.filter.page is u64 && contract_iterator.filter.page >= max_page_iteration {
			break
		}

		iterator_contracts := contract_iterator.next()
		if iterator_contracts != none {
			iterator_available_contracts << iterator_contracts
		} else {
			break //if the page is empty the next function will return none
		}
	}
	println(iterator_available_contracts.len)
}