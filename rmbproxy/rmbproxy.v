module rmbproxy
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


//if rmbid is 0, means we work in local mode
// 		src_twinid		 u32    //which twin is responsible for executing on behalf of actor (0 is local)
// 		src_rmbids		 []u32  //how do we find our way back, if 0 is local, can be more than 1
// 		ipaddr			 string
fn (mut rmbp RMBProxy) process() ! {
	t_wsserver := spawn rmbp.wsserver.listen()

	mut rmb := &rmbp.rmbc
	mut guid := ""
	for {
		guid = rmb.redis.rpop("jobs.queue.out") or {
			println(err)
			panic("error in jobs queue")
		}
		if guid.len > 0 {		
			println("FOUND OUTGOING GUID:$guid")
			mut job := rmb.job_get(guid)!
			if job.twinid == u32(0) || job.twinid == u32(0) {
				rmb.redis.lpush("jobs.queue.in", "${job.guid}")!
				now := time.now().unix_time()
				rmb.redis.hset("rmb.jobs.in", "${job.guid}", "$now")!
			} else {
				rmb.jobs.clients.$rmbclientid
			}
			println(job)
		}
		println("sleep")
		time.sleep(time.second)
		// mut job4:=rmb.job_get(qout)!
		// println(job4)
	}
	rmbp.wsserver.close()
	t_wsserver.wait() or {
		println(err)
		panic("error while waiting for the server") 
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
		data := json.decode(map[string]string, msg.payload) or {
			println("RMBProxy: Failed to decode payload")
			return 
		}

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