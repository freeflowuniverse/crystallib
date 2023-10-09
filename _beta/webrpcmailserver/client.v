module mail

import log
import freeflowuniverse.crystallib.jsonrpc
import freeflowuniverse.crystallib.rpcwebsocket
import x.json2

// client for reverse echo json rpc ws server
struct MailOpenRpcClient {
	jsonrpc.JsonRpcClient
}

pub fn (mut client MailOpenRpcClient) close() ! {
	_ := client.send_json_rpc[string, json2.Null]('close', '', 1000)!
}

pub fn (mut client MailOpenRpcClient) login(params LoginParams) ! {
	_ := client.send_json_rpc[LoginParams, json2.Null]('login', params, 1000)!
}

pub fn (mut client MailOpenRpcClient) select_(params SelectParams) !SelectData {
	return client.send_json_rpc[SelectParams, SelectData]('select_', params, 1000)!
}

pub fn (mut client MailOpenRpcClient) create(options CreateParams) ! {
	_ := client.send_json_rpc[CreateParams, json2.Null]('create', options, 1000)!
}

pub fn (mut client MailOpenRpcClient) delete(mailbox string) ! {
	_ := client.send_json_rpc[string, json2.Null]('delete', mailbox, 1000)!
}

pub fn (mut client MailOpenRpcClient) rename(params RenameParams) ! {
	_ := client.send_json_rpc[RenameParams, json2.Null]('rename', params, 1000)!
}

pub fn (mut client MailOpenRpcClient) subscribe(mailbox string) ! {
	_ := client.send_json_rpc[string, json2.Null]('subscribe', mailbox, 1000)!
}

pub fn (mut client MailOpenRpcClient) unsubscribe(mailbox string) ! {
	_ := client.send_json_rpc[string, json2.Null]('unsubscribe', mailbox, 1000)!
}

pub fn (mut client MailOpenRpcClient) list(options ListOptions) ! {
	_ := client.send_json_rpc[ListOptions, json2.Null]('list', options, 1000)!
}

pub fn (mut client MailOpenRpcClient) status(options StatusParams) !string {
	return client.send_json_rpc[StatusParams, string]('status', options, 1000)!
}

pub fn (mut client MailOpenRpcClient) append(options AppendParams) !bool {
	return client.send_json_rpc[AppendParams, bool]('append', options, 1000)!
}

pub fn (mut client MailOpenRpcClient) poll(allow_expunge bool) ! {
	_ := client.send_json_rpc[bool, json2.Null]('poll', allow_expunge, 1000)!
}

pub fn (mut client MailOpenRpcClient) idle() ! {
	_ := client.send_json_rpc[string, json2.Null]('idle', '', 1000)!
}

// run_client creates and runs jsonrpc client
// uses reverse_echo method to perform rpc and prints result
pub fn new_client(mut transport rpcwebsocket.RpcWsClient) !&MailOpenRpcClient {
	mut logger := log.Logger(&log.Log{
		level: .debug
	})

	mut client := MailOpenRpcClient{
		transport: transport
	}
	spawn transport.run()
	return &client
}
