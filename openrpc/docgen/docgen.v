module docgen

import v.doc
import v.pref
import freeflowuniverse.crystallib.openrpc { OpenRPC }

// configuration parameters for OpenRPC Document generation.
[params]
pub struct DocGenConfig {
	title       string // Title of the JSON-RPC API
	description string // Description of the JSON-RPC API
	version     string = '1.0.0' // OpenRPC Version used
	source      string // Source code directory to generate doc from
	strict      bool   // Strict mode generates document for only methods and struct with the attribute `openrpc`
}

// docgen generates OpenRPC Document struct for JSON-RPC API defined in the config params.
// returns generated OpenRPC struct which can be encoded into json using `openrpc.OpenRPC.encode()`
pub fn docgen(config DocGenConfig) !OpenRPC {
	$if debug {
		eprintln('Loading OpenRPC specifications from path: ${config.source}')
	}

	mut parser := new()
	parser.parse(config.source)!

	return OpenRPC{
		info: openrpc.Info{
			title: config.title
			version: config.version
		}
		methods: parser.methods
		components: openrpc.Components{
			schemas: parser.schemas
			examples: parser.examples
		}
	}
}
