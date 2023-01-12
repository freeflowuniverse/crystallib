module rmbproxy
import freeflowuniverse.crystallib.encoder
import freeflowuniverse.crystallib.rmbclient

import log
import net.websocket

pub struct RMBProxy {
pub mut:
	rmbc &rmbclient.RMBClient
	wsserver &websocket.Server
	logger &log.Logger
}

pub fn new(port int, log_level log.Level) !RMBProxy {
	mut rmbc := rmbclient.new()!
	mut logger := log.Logger(&log.Log{ level: log_level })
	mut wsserver := websocket.new_server(.ip, port, "", websocket.ServerOpt{logger: &logger})
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
		logger: &logger
	}
	wsserver.on_message(RMBProxy.on_message)
	return rmbp
}

fn (mut rmbp RMBProxy) on_message(mut client websocket.Client, msg &websocket.Message) ! {
	if msg.opcode == .binary_frame {
		decoder := encoder.decoder_new(msg.payload)
		data := decoder.get_map_string()

		if !("cmd" in data) {
			println("RMBProxy: Invalid message <${data}>: Does not contain cmd")
			return 
		}

		if !(data["cmd"] in rmbp.handlers) {
			println("RMBProxy: Invalid message <${data}>: Unknown command ${data['cmd']}")
			return 
		}

		rmbp.handlers[data["cmd"]].handle(data) or {
			println("RMBProxy: Error while handeling message <${data}>: $err")
			return
		}
	}
}


//run the rmb processor
pub fn run(port int, debug bool) ! {
	level := match debug {
		true { .debug }
		else { .info }
	}
	mut rmbproxy := new(port, level)!
	rmbproxy.wsserver.listen()
}