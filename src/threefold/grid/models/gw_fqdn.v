module models

import json

pub struct GatewayFQDNProxy {
	tls_passthrough bool
	backends        []string
	network         ?string
	fqdn            string
}

pub fn (g GatewayFQDNProxy) challenge() string {
	mut output := ''
	output += g.fqdn
	output += '${g.tls_passthrough}'
	for b in g.backends {
		output += b
	}
	output += g.network or { '' }

	return output
}

pub fn (g GatewayFQDNProxy) to_workload(args WorkloadArgs) Workload {
	return Workload{
		version: args.version or { 0 }
		name: args.name
		type_: workload_types.gateway_fqdn
		data: json.encode(g)
		metadata: args.metadata or { '' }
		description: args.description or { '' }
		result: args.result or { WorkloadResult{} }
	}
}
