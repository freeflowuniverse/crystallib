# ZOS

V OpenRPC ZOS client and document generator.

The openrpc document is generated from the client method prototypes. The goal is to easily generate the OpenRPC specs for ZOS, and also have a client in V. To change and regenerate the OpenRPC document, simply change client functions, install the [OpenRPC CLI](../openrpc/README.md) and run 

```bash
openrpc docgen -t "Zero OS OpenRPC API" -o generated methods.v
```

`openrpc docgen -help` for more info. 

Read more about OpenRPC Document generation at [crystallib.core.openrpc](../openrpc/README.md)



- [playground](https://playground.open-rpc.org/?uiSchema%5BappBar%5D%5Bui:splitView%5D=false&schemaUrl=https://raw.githubusercontent.com/freeflowuniverse/crystallib/development_db/research/zos/generated/openrpc.json&uiSchema%5BappBar%5D%5Bui:input%5D=false)


Can also manual use the playground: https://playground.open-rpc.org/ and copy paste the openrpc.json document in it.

