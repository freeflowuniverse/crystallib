# Gateway name Example

The gateway name example exposes the following functionality:

- deploying a gateway name instance with custom specs.
- reading a gateway name instance from the grid.
- deleting a gateway name instance from the grid.

## CLI Arguments

The [gateway name cli](../../../../examples/tfgrid/gateway_name.v) has the following arguments:

- mnemonic: user mnemonic.
- network: chain network to use. defaults to `dev`
- address: address of web3proxy to connect to. defaults to `ws://127.0.0.1:8080`.
- operation: this is the operation that you want to perform. must be one of `deploy`, `get`, or `delete`.
- debug: true to print debug logs.

### Deploy Operation Arguments

- name: identifier for the instance, must be unique
- node_id: node id to deploy on.
- tls_passthrough: if false will terminate the certificates on the gateway, else will passthrough the request as is.
- backend: backend of the gateway
  
```sh
    v run gateway_name.v --network main --mnemonic "YOUR MNEMONIC" --operation deploy --name mygateway_name --node_id 1 --backend http://1.1.1.1:9000
```

### Get Operation Arguments

- name: name of the gateway_name instance

```sh
    v run gateway_name.v --network main --mnemonic "YOUR MNEMONIC" --operation get --name mygateway_name
```

### Delete Operation Arguments

- name: name of the gateway_name instance

```sh
    v run gateway_name.v --network main --mnemonic "YOUR MNEMONIC" --operation delete --name mygateway_name
```
