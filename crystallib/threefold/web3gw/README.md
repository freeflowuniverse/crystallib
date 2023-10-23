# The V library

This section of the repository contains the implementation of a V client library. For each client that the web3 proxy supports there will be a folder here. Inside that folder there will be a struct representing the client and a function to create it.

For example:

```vlang
[noinit; openrpc: exclude]
pub struct TfChainClient {
mut:
 client &RpcWsClient
}

[openrpc: exclude]
pub fn new(mut client RpcWsClient) TfChainClient {
 return TfChainClient{
  client: &client
 }
}
```

Note that in the above example, the `openrpc: exclude` attribute is used to tell the OpenRPC Document generator to exclude the client struct and factory function from the OpenRPC Document.

For each of the remote procedure calls on the server side (in go) there should be a V function. You can find two examples below. The first example does not return anything, the second does. Each function sends a json rpc message using the RpcWsClient. That function has two generics (the values between square brackets). The first generic defines the type of parameters that you want to send (this will be serialized in the params field of the json 2.0 rpc request). The second defines the type of object that you expect to receive (the result field of a json 2.0 rpc response).

There is one slight issue at this moment. The server only supports sending the parameters of remote procedure calls $by order$ for now. This means we have to send a list of objects to the server. In V you can of course only send a list of objects of the same type. Therefore we agreed to send a list of only one object, which is the arguments that the corresponding function on the server side requires. The first generic will therefore always be a list of a specific type of object.

Always add documentation for each of the calls, this documentation is used when generating the documentation for openrpc. Documenting the structs required to send data is highly appreciated too! That will also be used when generating the openrpc documentation.

For example:

```vlang
// Transfer some amount to some destination. The destionation should be a SS58 address.
pub fn (mut t TfChainClient) transfer(args Transfer) ! {
 _ := t.client.send_json_rpc[[]Transfer, string]('tfchain.Transfer', [args], tfchain.default_timeout)!
}

// Ask for the balance of an entity using this call. The address should be a SS58 address.
pub fn (mut t TfChainClient) balance(address string) !i64 {
 return t.client.send_json_rpc[[]string, i64]('tfchain.Balance', [address], tfchain.default_timeout)!
}

```

To use the examples, check [examples](../../../examples/threefold/web3gw/examples)
