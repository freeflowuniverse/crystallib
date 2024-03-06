module rpcprocessor

import freeflowuniverse.crystallib.clients.redisclient // Assuming this is the path to the Redis client
import freeflowuniverse.crystallib.data.rpcwebsocket // Assuming this is the path to the Redis client
import freeflowuniverse.crystallib.data.jsonrpc
import net.websocket
import time
import vweb
import log

@[heap]
struct RPCProcessor {
mut:
    redis_client redisclient.Redis
    handler_queue string = 'rpc_handler_queue'
    result_queue string = 'rpc_result_queue'
    // ws_server    rpcwebsocket.RpcWsServer // Placeholder for your WebSocket server type
    handler_queues map[string]redisclient.RedisQueue
    ui RPCProcessorUI
    handlers []IHandler
}

pub struct Handler {
    name string
    queue redisclient.RedisQueue
}

struct RPCRequest {
    id      string
    payload string
}

struct RPCResponse {
    id      string
    result  string
}

@[params]
pub struct ProcessorConfig {
    redis_client redisclient.Redis
}

pub fn new(config ProcessorConfig) !RPCProcessor {
    // Initialize Redis client

    processor := RPCProcessor{
        redis_client: config.redis_client
    }

    return processor
}

pub fn (mut p RPCProcessor) register_handler(handler IHandler) {
    handler_queue := p.redis_client.queue_get(queue)
    p.handler_queues[method] = handler_queue
    p.handlers << 
} 

struct RPCProcessorUI {
    vweb.Context
}

pub fn (mut p RPCProcessor) run_ui() ! {
    vweb.run(p.ui, 8080)
}

pub fn (mut ui RPCProcessorUI) index() vweb.Result {
    return ui.html($tmpl('./templates/index.html'))
}

pub fn (mut ui RPCProcessorUI) handler() vweb.Result {
    return ui.html($tmpl('./templates/handler.html'))
}

fn (mut p RPCProcessor) handler(client &websocket.Client, message string) string {
    method := jsonrpc.jsonrpcrequest_decode_method(message) or { return '' }
	id := jsonrpc.jsonrpcrequest_decode_id(message) or { return '' }
	p.redis_client.hset('rpcs.db', id, message) or {
        panic(err)
    }

	// mut q_handler := p.redis_client.queue_get(method)
    p.handler_queues[method].add(id) or {
        panic(err)
    }

	mut q_response := p.redis_client.queue_get(id)
    response := q_response.get(100) or {
        panic(err)
    }
    println('message: ${response}')
    return response
}
