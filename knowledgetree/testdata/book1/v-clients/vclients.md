# web3 proxy clients for v

## RPC websocket client

Most clients listed below need an RPC websocket client to the [web3proxy server](../server/server.md).

Create an RPC client to a web3proxy server running on localhost:

```v
import freeflowuniverse.crystallib.rpcwebsocket { RpcWsClient }
 
 ...

 server_address = 'ws://127.0.0.1:8080'
 mut logger := log.Logger(&log.Log{
  level: if debug_log { .debug } else { .info }
 })

 mut rpc_client := rpcwebsocket.new_rpcwsclient(server_address, &logger) or {
  logger.error('Failed creating rpc websocket client: ${err}')
  exit(1)
 }
```

## Clients

- [Ethereum](./ethereum/ethereum.md)
- [Stellar](./stellar/stellar.md)
