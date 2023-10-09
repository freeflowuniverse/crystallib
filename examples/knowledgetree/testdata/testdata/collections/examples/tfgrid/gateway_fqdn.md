# Gateway FQDN Example

The gateway fqdn example exposes the following functionality:

- deploying a gateway fqdn instance with custom specs.
- reading a gateway fqdn instance from the grid.
- deleting a gateway fqdn instance from the grid.

## CLI Arguments

The [gateway fqdn cli](../../../../examples/tfgrid/gateway_fqdn.v) has the following arguments:

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
- fqdn: FQDN of the gateway
  
```sh
    v run gateway_fqdn.v --network main --mnemonic "YOUR MNEMONIC" --operation deploy --name mygateway_fqdn --node_id 1 --backend http://1.1.1.1:9000 --fqdn mydomain.com
```

### Get Operation Arguments

- name: name of the gateway_fqdn instance

```sh
    v run gateway_fqdn.v --network main --mnemonic "YOUR MNEMONIC" --operation get --name mygateway_fqdn
```

### Delete Operation Arguments

- name: name of the gateway_fqdn instance

```sh
    v run gateway_fqdn.v --network main --mnemonic "YOUR MNEMONIC" --operation delete --name mygateway_fqdn
```
