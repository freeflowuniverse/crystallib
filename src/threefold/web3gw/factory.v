module vclient

import os

[params]
pub struct Arguments {
	rpc_server_address string = 'http://127.0.0.1:8080'
}

fn new(args_ Arguments) !RPCWSCLIENT {
	mut args := args_

	if !'MNEMONIC' in os.env {
		return error("Specify 'MNEMONICS' as ENV env. do 'export MNEMONIC=...'")
	}

	if 'RPCADDR' in os.env {
		args.rpc_server_address = os.env('RPCADDR')
	}

	mnemonic := os.env('MNEMONIC')

	// mut logger := log.Logger(&log.Log{
	// 	level: if debug_log { .debug } else { .info }
	// })

	// TODO:fill in args
	mut myclient := rpcwebsocket.new_rpcwsclient(args, &logger) or {
		logger.error('Failed creating rpc websocket client: ${err}')
		exit(1)
	}
	// TODO: return RPCWSCLIENT
}
