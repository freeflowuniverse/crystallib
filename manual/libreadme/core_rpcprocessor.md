# RPCProcessor

## Overview
`rpcprocessor` is a high-performance, scalable module designed to facilitate Remote Procedure Calls (RPCs) in distributed systems. Built with the V programming language, this module seamlessly integrates WebSocket communication and Redis queues to efficiently handle and route RPCs. Ideal for microservices architectures and asynchronous task processing, `rpcprocessor` ensures reliable message delivery and processing with minimal latency.

## Features

- **WebSocket Integration**: Leverages WebSockets for real-time, bidirectional communication.
- **Redis Queue Management**: Utilizes Redis queues to maintain and manage RPC requests and responses, ensuring organized and efficient handling.
- **Scalable Architecture**: Designed to scale with your application, handling increased loads with ease.
- **Simple API**: Offers a straightforward and intuitive API, making it easy to integrate and use within your projects.
- **Asynchronous Processing**: Supports asynchronous processing, enabling non-blocking operations and improved performance.

## Requirements

- V Programming Language
- Redis Server

## Installation

To include `rpcprocessor` in your project, add the following import statement:

```v
import rpcprocessor
```

Ensure you have a running Redis instance for rpcprocessor to connect to. Configuration details for the Redis connection can be specified within the module's initialization parameters.

## Usage

### Initializing the Server

To start using rpcprocessor, initialize the server with the necessary configuration:

```
import rpcprocessor

fn main() {
    config := rpcprocessor.Config{
        redis_address: 'localhost:6379',
        ws_port: 8080,
    }
    server := rpcprocessor.new_server(config)
    server.start()
}
```

### Handling RPCs

Define your RPC handlers and register them with the server. rpcprocessor will route incoming RPCs to the appropriate handler based on the configuration.

```
server.register_handler('my_rpc', my_rpc_handler)

fn my_rpc_handler(request rpcprocessor.Request) rpcprocessor.Response {
    // Process the request
    return rpcprocessor.Response{
        result: 'Processed result',
    }
}
```

### Fetching Results

Once an RPC is processed, rpcprocessor fetches the result from the corresponding Redis queue and returns it to the caller.