module jsonrpc


struct MyParams {
pub mut:
	attr1 string
}

struct MyResult {
pub mut:
	resulta string
}

fn test_jsonrpcrequest() {
	params := MyParams{
		attr1: 'test'
	}
	req := new_jsonrpcrequest('mymethod', params)
	assert req.to_json() == '{"jsonrpc":"2.0","method":"mymethod","params":{"attr1":"test"},"id":"${req.id}"}'
}

fn test_jsonrpcresponse() {
	id := 'some id from the original request'
	result := MyResult{
		resulta: 'this is some data'
	}
	resp := new_jsonrpcresponse(id, result)
	assert resp.to_json() == '{"jsonrpc":"2.0","result":{"resulta":"this is some data"},"id":"some id from the original request"}'
}

fn test_jsonrpcerror() {
	id := 'some id from the original request'
	result := MyResult{
		resulta: 'this is some data'
	}
	error := new_jsonrpcerror(id, 15, 'The provided twinid does not exist', 'The twinid 15 is not a valid twinid!')
	assert error.to_json() == '{"jsonrpc":"2.0","error":{"code":15,"message":"The provided twinid does not exist","data":"The twinid 15 is not a valid twinid!"},"id":"some id from the original request"}'
}

fn test_decode_jsonrpcerror() {
	data := '{"jsonrpc":"2.0","error":{"code":15,"message":"The provided twinid does not exist","data":"The twinid 15 is not a valid twinid!"},"id":"some id from the original request"}'

	error := jsonrpcerror_decode(data)!
	assert error.jsonrpc == jsonrpc_version
	assert error.error.code == 15
	assert error.error.message == "The provided twinid does not exist"
	assert error.error.data == "The twinid 15 is not a valid twinid!"
	assert error.id == "some id from the original request"
}

fn test_decode_jsonrpcresult() {
	data := '{"jsonrpc":"2.0","result":{"resulta":"this is some data"},"id":"some id from the original request"}'

	resp_or_error := jsonrpcresponse_decode[MyResult](data)!
	assert resp_or_error.jsonrpc == jsonrpc_version
	assert resp_or_error.result == MyResult{
		resulta: 'this is some data'
	}

	assert resp_or_error.id == "some id from the original request"
}