module jsonrpc

// Default JSONRPC errors, as defined in https://www.jsonrpc.org/specification
const parse_error = InnerJsonRpcError{
	code: 32700
	message: 'Parse error'
	data: 'Invalid JSON was received by the server. An error occurred on the server while parsing the JSON text.'
}
const invalid_request = InnerJsonRpcError{
	code: 32600
	message: 'Invalid Request'
	data: 'The JSON sent is not a valid Request object.'
}
const method_not_found = InnerJsonRpcError{
	code: 32601
	message: 'Method not found'
	data: 'The method does not exist / is not available.'
}
const invalid_params = InnerJsonRpcError{
	code: 32602
	message: 'Invalid params'
	data: 'Invalid method parameter(s).'
}
const internal_error = InnerJsonRpcError{
	code: 32603
	message: 'Internal Error'
	data: 'Internal JSON-RPC error.'
}

pub fn new_error(id string, error InnerJsonRpcError) JsonRpcError {
	return JsonRpcError{
		jsonrpc: jsonrpc_version
		error: error
		id: id
	}
}

pub fn (err InnerJsonRpcError) msg() string {
	return err.message
}

pub fn (err InnerJsonRpcError) code() int {
	return err.code
}
