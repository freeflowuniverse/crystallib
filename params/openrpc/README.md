# OpenRPC

OpenRPC V library. Model for OpenRPC, client code generation, and specification generation from code.

## Definitions

- OpenRPC Specifications: Specifications that define standards for describing JSON-RPC API's.

- [OpenRPC Document](https://spec.open-rpc.org/#openrpc-document): "A document that defines or describes an API conforming to the OpenRPC Specification."

- OpenRPC Client: An API Client (using either HTTP or Websocket) that governs functions (one per RPC Method defined in OpenRPC Document) to communicate with RPC servers and perform RPCs.

- OpenRPC Client module in V: An OpenRPC Client in the form of a V module. The module must have the following files:
  - a model.v file, in which structs of components defined in the OpenRPC Document reside
  - a client.v file, in which the client struct is defined, alongside client methods that are used for communicating with a JSON-RPC API server. (for instance a send_rpc method that is used in all the client methods)
  - a methods.v file, in which methods of the client reside

## Installation

Follow crystallib installation instructions.

## Getting started

See [OpenRPC Document Generator](./docgen/README.md/#getting-started)