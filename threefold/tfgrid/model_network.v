module tfgrid

pub struct Network {
pub:
	name                 string
	ip_range             string = '10.1.0.0/16'
	add_wireguard_access bool   [json: 'add_wireguard_access'] // this adds wireguard access node
	description          string
}

struct NetworkResult {
pub:
	wireguard_config string
}
