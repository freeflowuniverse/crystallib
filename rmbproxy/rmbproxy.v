module rmbproxy
import freeflowuniverse.crystallib.encoder
import freeflowuniverse.crystallib.rmbclient
import freeflowuniverse.crystallib.resp

import net.websocket
import time

pub struct RMBProxy {
pub mut:
	rmbc &rmbclient.RMBClient
	wsserver &websocket.Server
}

pub fn new(client &rmbclient.RMBClient) !RMBProxy {
	mut wsserver := websocket.new_server(.ip, port, "", websocket.ServerOpt{})
	mut handlers := map[string]RMBProxyHandler{}
	handlers["job.send"] = JobSendHandler { rmbc: client }
	handlers["twin.set"] = TwinSetHandler { rmbc: client }
	handlers["twin.del"] = TwinDelHandler { rmbc: client }
	handlers["twin.get"] = TwinGetHandler { rmbc: client }
	handlers["twinid.new"] = TwinIdNewHandler { rmbc: client }
	handlers["proxies.get"] = ProxiesGetHandler { rmbc: client }
	mut rmbp := RMBProxy {
		rmbc: client
		wsserver: wsserver
	}
	wsserver.on_message(RMBProxy.on_message)
	return rmbp
}

pub fn (mut rmbp RMBProxy) send_action_job(action_job &rmbclient.ActionJob) ! {
	action_json := action_job.dumps()
	// TODO ecrypt data with public key of twin id who has to execute job
	action_json_encrypted := action_json
	mut data := maps[string]string {}
	data["cmd"] = "job.send"
	data["signature"] = "//TODO!!!"
	data["payload"] = action_json_encrypted

	encoder := encoder.encoder_new()
	encoder.add_map_string(data)

	for rmb_proxy in rmbp.rmbc.rmb_proxy_ips {
		rmbp.send_message(rmb_proxy, encoder.data) or {
			println("RMBProxy: Failed sending to rmb proxy ${rmb_proxy}: $err")
			// lets try the next one
			continue
		}
		// we were able to send the message => return
		return
	}
}

fn (mut rmbp RMBProxy) send_message(address string, data string) ! {
	client := websocket.new_client(address, websocket.ClientOpt{}) or {
		return error("Failed to create websocket client: $err")
	}
	client.connect() or {
		return error("Failed to connect to server: $err")
	}

	_ := client.write(data.bytes(), .binary_frame) or {
		return error("Failed to write to server: $err")
	}

	client.close(0, "Closing connection")!
}

fn (mut rmbp RMBProxy) on_message(mut client websocket.Client, msg &websocket.Message) ! {
	if msg.opcode == .binary_frame {
		decoder := encoder.decoder_new(msg.payload)
		data := decoder.get_map_string()

		if not "cmd" in data {
			println("RMBProxy: Invalid message <${data}>: Does not contain cmd")
			return 
		}

		if not data["cmd"] in rmbp.handlers {
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
pub fn process() ! {
	mut rmbp := new()!
	rmbp.process()!
}