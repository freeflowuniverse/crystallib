module docgen

import json
import os

fn test_docgen_simple() ! {
	client_path := os.dir(@FILE).all_before_last('/') + '/examples/openrpc_client'
	doc := docgen(
		title: 'test'
		source: client_path
	)!
	panic(doc.encode()!)
}

fn test_docgen() ! {
	client_path := os.dir(@FILE).all_before_last('/') + '/examples/openrpc_client'
	doc := docgen(
		title: 'test'
		source: client_path
	)!
	panic(doc.encode()!)
}
