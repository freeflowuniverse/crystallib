@[heap]
struct TesterHandler {
        state Tester
}

// handle handles an incoming JSON-RPC encoded message and returns an encoded response
pub fn (handler TesterHandler) handle(msg string) string {
        method := jsonrpc.jsonrpcrequest_decode_method(msg)!
        match method {
                'test_notification_method' {
                        jsonrpc.notify[string](msg, handler.state.test_notification_method)!
                }
                'test_invocation_method' {
                        return jsonrpc.invoke[string](msg, handler.state.test_invocation_method)!
                }
                'test_method' {
                        return jsonrpc.call[string, string](msg, handler.state.test_method)!
                }
                'test_method_structs' {
                        return jsonrpc.call[Key, Value](msg, handler.state.test_method_structs)!
                }
                else {
                        return error('method ${method} not handled')
                }
        }
        return error('this should never happen')
}