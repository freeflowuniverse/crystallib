module jsonrpc

import freeflowuniverse.crystallib.core.codemodel
import freeflowuniverse.crystallib.core.codeparser
import os

const testpath = os.dir(@FILE) + '/testdata'

fn test_generate_handler() {
	code := codeparser.parse_v('${jsonrpc.testpath}/testfunction.v')!
	function := code[0] as codemodel.Function
	handler := generate_handler(function)
}

fn test_generate_server() {
	code := codeparser.parse_v('${jsonrpc.testpath}/testmodule/testfunctions.v')!
	server_code := generate_server(code)
}

fn test_servergen() {
	servergen(
		source: '${jsonrpc.testpath}/testmodule/testfunctions.v'
		destination: '${jsonrpc.testpath}/testserver'
		only_pub: true
	)!
	panic('g')
}
