module rpcwebsocket

import net.websocket

pub fn echo_handler(client &websocket.Client, msg string) !string {
	return 'echo'
} 