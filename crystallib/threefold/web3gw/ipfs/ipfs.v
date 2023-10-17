module ipfs

import freeflowuniverse.crystallib.data.rpcwebsocket { RpcWsClient }

const (
	default_timeout = 500000
)

[openrpc: exclude]
[noinit]
pub struct IpfsClient {
mut:
	client &RpcWsClient
}

[openrpc: exclude]
pub fn new(mut client RpcWsClient) IpfsClient {
	return IpfsClient{
		client: &client
	}
}

// Store content on ipfs, returns cid
pub fn (mut e IpfsClient) store_file(content []byte) !string {
	return e.client.send_json_rpc[[][]byte, string]('ipfs.StoreFile', [content], ipfs.default_timeout)!
}

// Gets file content from ipfs based on cid
pub fn (mut e IpfsClient) get_file(cid string) !string {
	return e.client.send_json_rpc[[]string, string]('ipfs.GetFile', [cid], ipfs.default_timeout)!
}

// Removes files based on cid
pub fn (mut e IpfsClient) remove_file(cid string) !bool {
	return e.client.send_json_rpc[[]string, bool]('ipfs.RemoveFile', [cid], ipfs.default_timeout)!
}

// remove all files from ipfs
pub fn (mut e IpfsClient) remove_all_files() ! {
	_ := e.client.send_json_rpc[[]string, string]('ipfs.RemoveAllFiles', []string{}, ipfs.default_timeout)!
}

// list all cids from ipfs
pub fn (mut e IpfsClient) list_cids() ![]string {
	return e.client.send_json_rpc[[]string, []string]('ipfs.ListCids', []string{}, ipfs.default_timeout)!
}
