module models

import json

pub struct GatewayNameProxy {
	tls_passthrough bool
	backends        []string // format?
	network         ?string  // format?
	name            string   // format?
}

pub fn (g GatewayNameProxy) challenge() string {
	mut output := ''
	output += g.name
	output += '${g.tls_passthrough}'
	for b in g.backends {
		output += b
	}
	output += g.network or { '' }

	return output
}

// GatewayProxyResult results
pub struct GatewayProxyResult {
pub mut:
	fqdn string
}

pub fn (g GatewayNameProxy) to_workload(args WorkloadArgs) Workload {
	return Workload{
		version: args.version or { 0 }
		name: args.name
		type_: workload_types.gateway_name
		data: json.encode(g)
		metadata: args.metadata or { '' }
		description: args.description or { '' }
		result: args.result or { WorkloadResult{} }
	}
}
