module openrpc

import jsonschema

fn test_encode() ! {
	doc := OpenRPC{
		info: Info{
			title: ''
			version: '1.0.0'
		}
		methods: []Method{}
	}
	encoded := doc.encode()!
	assert encoded == '{"openrpc":"2.0.0","info":{"version":"1.0.0"}}'
}

fn test_encode_2() ! {
	doc := OpenRPC{
		info: Info{
			title: ''
			version: '1.0.0'
		}
		methods: [
			Method{
				name: 'method_name'
				summary: 'summary'
				description: 'description for this method'
				deprecated: true
				params: [
					ContentDescriptor{
						name: 'sample descriptor'
					},
				]
			},
		]
	}
	encoded := doc.encode()!
	assert encoded == '{"openrpc":"2.0.0","info":{"version":"1.0.0"},"methods":[{"name":"method_name","summary":"summary","description":"description for this method","params":[{"name":"sample descriptor"}],"paramStructure":"default"}]}'
}
