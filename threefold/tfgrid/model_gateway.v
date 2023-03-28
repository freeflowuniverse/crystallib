module tfgrid

[params]
pub struct GatewayFQDN {
pub:
	name            string   [required]
	node_id         u32      [required]
	tls_passthrough bool
	backends        []string [required]
	fqdn            string
}

pub struct GatewayFQDNResult {
pub:
	name            string   [required]
	node_id         u32      [required]
	tls_passthrough bool
	backends        []string [required]
	fqdn            string
	// computed
	contract_id u32
}

[params]
pub struct GatewayName {
pub:
	name            string   [required]
	node_id         u32
	tls_passthrough bool
	backends        []string [required]
}

pub struct GatewayNameResult {
pub:
	name            string   [required]
	node_id         u32
	tls_passthrough bool
	backends        []string [required]
	// computed
	fqdn             string // the full domain name
	name_contract_id u32
	contract_id      u32
}


