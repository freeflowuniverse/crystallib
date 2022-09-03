module twinclient2

// general message between client <-> server
pub struct Message {
pub:
	id string
	// event type
	event string
	// data as json
	data string
}

pub enum Events {
	client_connected
	calculate_address_balance
	calculate_addresses_balances
}

pub struct InvokeRequest {
mut:
	function string
	// json encoded args
	args string
}
