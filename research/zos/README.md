# ZOS

V OpenRPC ZOS client and document generator.

The openrpc document is generated from the client method prototypes. The goal is to easily generate the OpenRPC specs for ZOS, and also have a client in V. To change and regenerate the OpenRPC document, simply change client functions, install the [OpenRPC CLI](../openrpc/README.md) and run `openrpc docgen -t "Zero OS OpenRPC API" -o <target_path> /path/to/crystallib/zos/methods.v`. `openrpc docgen -help` for more info. 

Read more about OpenRPC Document generation at [crystallib.core.openrpc](../openrpc/README.md)

