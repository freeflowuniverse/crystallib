# Server

The server is the main component of the web3 proxy. It is responsible for the following:

- Serving the web3 proxy API
- Providing a websocket connection to the client

## Running the server

Available flags:

- `--debug`: enable debug logging
- `--port`: port to listen on
- `--ipfs`: enable IPFS functionality
- `--ipfs-port`: port to listen on for IPFS

The server can be run with the following command:

```shell
go build && ./server --debug
```

## Lib

The lib folder contains all the client code for the web3 proxy. It is used by the server to communicate with the client.

## Examples

Examples are available for all implemented clients. See the subfolder for all examples available for implemented clients.