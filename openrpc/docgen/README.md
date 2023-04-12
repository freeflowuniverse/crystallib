# OpenRPC Document Generator

## Introduction

The OpenRPC Document Generator generates a [JSON-RPC](https://www.jsonrpc.org/) API description conforming to [OpenRPC Specifications](https://spec.open-rpc.org/), from an [OpenRPC client module]() written in V.

## Getting started

To use the document generator, you need to have a V module with at least one V file.

The recommended way to generate an OpenRPC document for a V module is to use the OpenRPC CLI.

`openrpc docgen .`

Running this command in a V client module's directory will generate an OpenRPC document from the code in the module and output it to a openrpc.json file in the same directory. See [client code compatability]() for information on how to format V client module to be compatible for OpenRPC Document Generation.

The following output parameter and source path argument can be used to generate an OpenRPC Document for a module that is in a different directory, and output the document in a desired path.

`openrpc docgen -o <output_path> <source_path>`

Run `openrpc docgen help` for more information. 

**Document generation using docgen module**



## OpenRPC Specification Generation

The OpenRPC specification generator, referred to as specification generator from here on after, generates an OpenRPC 2.0 compliant JSON specification for RPC methods in a V project.

### Methods

The specification generator creates method specification for RPC methods that have the attribute `[openrpc]`. The method specification generated includes schemas and descriptions of the parameters and result a method takes in and returns.

### Parameter Descriptions

If a method takes a struct as parameters, then the parameter specification for openrpc is generated entirely from the params struct. The description of each parameter is generated from the 

For instance, below is a parameter struct for the example method.

```go

[params]
struct ExampleParams {
    number int
    word string
    wordlist []string
}

// example_method demonstrates an example
[openrpc]
pub fn example_method(params ExampleParams) {}
```

Using a params struct for RPC method definition is the recommended best practice for openrpc specification generation. This allows for the generator to directly match parameters with their commented descriptions.

While parameter specification can also be generated from parameters defined in method definition, comments on these methods need to follow a strict guideline for the generator to correctly parse parameter descriptions. 

Method parameters that are not defined in a separate params struct must be described in the following ways:
- The parameter descriptions must be above the method definition, like the method description itself
- The parameter descriptions must be below the method description comments
- Each parameter should be described in a separate comment and parameter descriptions must be continuous
- Parameter descriptions must start with the parameter variables key as defined in the function definition.

```go
// example_method demonstrates an example
// number is the index of the word in wordlist which this method does something with
// wordlist is a list of words 
[openrpc]
pub fn example_method(number int, wordlist []string) {}
```

If parameter descriptions do not follow these guidelines, the generator may fail to correctly parse these descriptions, thus failing to generate the intended specifications for the parameters. 

### Return Descriptions

If a method takes a struct as parameters, then the parameter specification for openrpc is generated entirely from the params struct. The description of each parameter is generated from the 

For instance, below is a parameter struct for the example method.

```go
[params]
struct ExampleParams {
    number int
    word string
    wordlist []string
}

// example_method demonstrates an example
[openrpc]
pub fn example_method(params ExampleParams) {}
```

Using a params struct for RPC method definition is the recommended best practice for openrpc specification generation. This allows for the generator to directly match parameters with their commented descriptions.

While parameter specification can also be generated from parameters defined in method definition, comments on these methods need to follow a strict guideline for the generator to correctly parse parameter descriptions. 

Method parameters that are not defined in a separate params struct must be described in the following ways:
- The parameter descriptions must be above the method definition, like the method description itself
- The parameter descriptions must be below the method description comments
- Each parameter should be described in a separate comment and parameter descriptions must be continuous
- 

```go
// example_method demonstrates an example
// number is the index of the word in wordlist which this method does something with
// wordlist is a list of words 
[openrpc]
pub fn example_method(number int, wordlist []string) {}
```

If parameter descriptions do not follow these guidelines, the generator may fail to correctly parse these descriptions, thus failing to generate the intended specifications for the parameters. 

