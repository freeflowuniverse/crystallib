# JSON RPC

## JSON RPC Call

Defined in `call.v`, the module provides two JSON RPC functions to call JSON RPC Methods. These act as wrappers functions that handle decoding encoding and errors for method calls to the function provided in the call parameters.

**To perform calls to methods that don't take any parameters, [`json2.Null`](https://modules.vlang.io/x.json2.html#Null) must be passed as the generic parameter for the function parameter**

**As with all JSONRPC functionalities, calls with multiple parameters aren't supported in these call functions. Function call parameters must be scaffolded into a single struct**

### Notifications

A JSON-RPC call that does not require any response data, or where the client does not expect any result (other than possibly an acknowledgement of receipt), is typically referred to as a "notification". In JSON-RPC 2.0, a notification is characterized by the absence of an "id" field in the request. This signals to the server that no response is expected. (chatgpt 4.0)


## Handler


### Handler Generation

Defined in [`handler_gen.v`](./handler_gen.v), handler generation allows for JSON RPC Handlers to be generated for a provided set of RPC Methods.

#### `handler_gen_test.v`

In the handler generation test, a handler is generated for a `Tester` struct which has methods with various parameters and return types. This tests ensures that the `handle` method generated for the `Handler` can exhaustively generate method call matchers for functions with varying return and parameter types.