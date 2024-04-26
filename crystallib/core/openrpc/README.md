# OpenRPC

OpenRPC V library. Model for OpenRPC, client code generation, and specification generation from code.

## Definitions

- OpenRPC Specifications: Specifications that define standards for describing JSON-RPC API's.
- [OpenRPC Document](https://spec.open-rpc.org/#openrpc-document): "A document that defines or describes an API conforming to the OpenRPC Specification."
- OpenRPC Client: An API Client (using either HTTP or Websocket) that governs functions (one per RPC Method defined in OpenRPC Document) to communicate with RPC servers and perform RPCs.

## OpenRPC Document Generation

The OpenRPC Document Generator generates a [JSON-RPC](https://www.jsonrpc.org/) API description conforming to [OpenRPC Specifications](https://spec.open-rpc.org/), from an OpenRPC Client module written in V.

To use the document generator, you need to have a V module with at least one V file.

The recommended way to generate an OpenRPC document for a V module is to use the OpenRPC CLI. Note below: if you are not using the openrpc cli as a binary executable, replace `openrpc` with `path_to_crystallib.core.openrpc/cli/cli.v` in the commands below

`openrpc docgen .`

Running this command in a V client module's directory will generate an OpenRPC document from the code in the module and output it to a openrpc.json file in the same directory. See [annotation code for openrpc document generation](#annotating-code-for-openrpc-document-generation) for information on how to format V client module to be compatible for OpenRPC Document Generation.

The following output parameter and source path argument can be used to generate an OpenRPC Document for a module that is in a different directory, and output the document in a desired path.

`openrpc docgen -o <output_path> <source_path>`

Run `openrpc docgen help` for more information. The CLI also has flags for filtering files and directories on input source, or choosing to generate document for only public struct and functions.


### Annotating code for OpenRPC Document Generation

The docgen module uses the [codeparser module](../../codeparser) to parse the source code for document generation. Therefore, the V code from which an OpenRPC Document will be generated must conform to the [V Annotation guidelines for code parsing](../../codeparser/README.md/#annotating-code-in-v), such that the document generator can harvest method and schema information such as descriptions from the comments in the code.

Below is an example OpenRPC compliant JSON Method and Schema descriptions generated from a properly annotated v file.

```go
// this is a description of the struct
struct Example {
    field0 string // this comment describes field0
    field1 int // this comment describes field1
}

// some_function is described by the words following the functions name
// - param0: this sentence after the colon describes param0
// - param1: this sentence after the colon describes param1
// returns the desired result, this sentence after the comma describes 'the desired result'
fn some_function(param0 string, param1 int) result []string {}
```

The following OpenRPC JSON Descriptions are generated from the above code:

```js
// schema generated from Example struct
{
    'name': 'Example'
    'description': 'this is a description of the struct'
    'properties': [
        'field0': {
            'type': 'string'
        },
        'field1': {
            'type': 'int'
        }
    ]
}
    
// method generated from some_function function
{
    'name': 'some_function'
    'description': 'is described by the words following the functions name'
    'params': [
        {
            'name': 'param0'
            'description': 'this sentence after the colon describes param0'
            'schema': {
                'type': 'string'
            }
        },
        {
            'name': 'param1'
            'description': 'this sentence after the colon describes param1'
            'schema': {
                'type': 'int'
            }
        }
    ]
    'result': {
        'name': 'the desired result'
        'description': 'this sentence after the comma describes \'the desired result\''
        'schema': {
            'type': 'array'
            'items': {
                'type': 'string'
            }
        }
    }
}
```
## Examples

The best way to understand how the document generation works is through the examples in this module

### Pet Store Example

Run this command from the root of the openrpc module.

```bash
v run cli/cli.v docgen -t 'PetStore API' -o examples/petstore_client -f 'client.v' examples/petstore_client
```
This generates an OpenRPC Document called PetStore API from the code in examples/petstore_client, excluding the client.v file, and writes it to examples/petstore_client/openrpc.json
