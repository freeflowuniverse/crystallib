import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.gridproxy.model

fn get_contracts_example() ! {
	mut gp_client := gridproxy.get(.dev, true)!

	mut filter := model.ContractFilter{}
	filter.state = 'Created'
	filter.contract_type = 'node'
	filter.twin_id = u64(800)
	contracts := gp_client.get_contracts(filter)!

	println(contracts)
}

fn get_contract_iterator_example() ! {
	mut gp_client := gridproxy.get(.dev, true)!

	max_page_iteration := u64(2) // set maximum pages to iterate on

	mut contract_iterator := gp_client.get_contracts_iterator(contract_type: 'node')
	mut contracts := []model.Contract{}
	for {
		if contract_iterator.filter.page is u64
			&& contract_iterator.filter.page >= max_page_iteration {
			break
		}

		iteration_contracts := contract_iterator.next()
		if iteration_contracts != none {
			contracts << iteration_contracts
		} else {
			break // if the page is empty the next function will return none
		}
	}
	println(contracts)
}

fn main() {
	get_contracts_example()!
	get_contract_iterator_example()!
}
