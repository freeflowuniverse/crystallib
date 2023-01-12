module rmbproxy
import freeflowuniverse.crystallib.encoder
import freeflowuniverse.crystallib.rmbclient

import log
import net.websocket

[heap]
pub struct RMBProxy {
pub mut:
	rmbc &rmbclient.RMBClient
	wsserver &websocket.Server
	logger &log.Logger
	handlers map[string]RMBProxyHandler
}

pub fn new(port int, logger &log.Logger) !RMBProxy {
	mut rmbc := rmbclient.new() or { 
		return error("Failed creating client: $err")
	}
	mut wsserver := websocket.new_server(.ip, port, "", websocket.ServerOpt{ logger: unsafe { logger } })
	mut handlers := map[string]RMBProxyHandler{}
	handlers["job.send"] = JobSendHandler { rmbc: &rmbc }
	handlers["twin.set"] = TwinSetHandler { rmbc: &rmbc }
	handlers["twin.del"] = TwinDelHandler { rmbc: &rmbc }
	handlers["twin.get"] = TwinGetHandler { rmbc: &rmbc }
	handlers["twinid.new"] = TwinIdNewHandler { rmbc: &rmbc }
	handlers["proxies.get"] = ProxiesGetHandler { rmbc: &rmbc }
	mut rmbp := RMBProxy {
		rmbc: &rmbc
		wsserver: wsserver
		logger: unsafe { logger }
		handlers: handlers
	}
	wsserver.on_connect(rmbp.on_connect)!
	wsserver.on_message(rmbp.on_message)
	wsserver.on_close(rmbp.on_close)
	return rmbp
}

fn (mut rmbp RMBProxy) on_close(mut client websocket.Client, code int, reason string) ! {
	rmbp.logger.info("Closing connection to client")
}

fn (mut rmbp RMBProxy) on_connect(mut client websocket.ServerClient) !bool {
	rmbp.logger.info("New client connection")
	return true
}

fn (mut rmbp RMBProxy) on_message(mut client websocket.Client, msg &websocket.Message) ! {
	if msg.opcode == .binary_frame {
		rmbp.logger.debug("New message: ${msg.payload}")
		mut decoder := encoder.decoder_new(msg.payload)
		data := decoder.get_map_string()

		if !("cmd" in data) {
			rmbp.logger.error("RMBProxy: Invalid message <${data}>: Does not contain cmd")
			return 
		}

		if !(data["cmd"] in rmbp.handlers) {
			rmbp.logger.error("RMBProxy: Invalid message <${data}>: Unknown command ${data['cmd']}")
			return 
		}

		rmbp.handlers[data["cmd"]].handle(data) or {
			rmbp.logger.error("RMBProxy: Error while handeling message <${data}>: $err")
			return
		}
		rmbp.logger.info("Successfully handled message of type: ${data["cmd"]}")
	}
}


//run the rmb processor
pub fn run(port int, logger &log.Logger) ! {
	mut rmbproxy := new(port, logger)!
	rmbproxy.wsserver.listen()!
}