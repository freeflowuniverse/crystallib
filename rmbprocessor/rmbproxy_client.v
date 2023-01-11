
module rmbprocessor
import freeflowuniverse.crystallib.rmbclient
import freeflowuniverse.crystallib.encoder
import net.websocket

//client to the rmb proxy
pub struct RMBProxyClient{
pub mut:
	rmb rmbclient.RMBClient
	twinid u32
	proxyipaddrs []string
	websocketclients []&websocket.Client //in reality its not string, its webdav clients, is more than 1
	websocketclient_active u8 //the current webdavclient which is being used, the one which is active
}

fn (mut cl RMBProxyClient) next_websocketclient() {
	cl.websocketclient_active += 1
	if cl.websocketclient_active >= cl.websocketclients.len {
		cl.websocketclient_active = 0
	}
}

fn (mut cl RMBProxyClient) write_first_successful(data []u8) !int {
	// we keep the amount of tries and we try all of the websocket clients in the worst case
	// but we always start from the last websocketclient that was successfull during the last call
	mut nbr_tries := 0
	for nbr_tries < cl.websocketclients.len {
		mut websocketclient:=cl.websocketclients[cl.websocketclient_active]
		if websocketclient.state != .open {
			websocketclient.connect() or {
				// failed to connect lets try the second one
				cl.next_websocketclient()
				nbr_tries += 1
				continue
			}
		}
		written_length := websocketclient.write(data, .binary_frame) or {
			// failed writing lets try the next one
			cl.next_websocketclient()
			nbr_tries += 1
			continue
		}
		// success
		return written_length
	}
	// failure
	return error("failed to connect to any of the rmb proxies")
}

//call first webdavclient first, if it doesn't work use next one, ...
fn (mut cl RMBProxyClient) rpc(data map[string]string) ! {
	mut encoder := encoder.encoder_new()
	encoder.add_map_string(data)

	_ := cl.write_first_successful(encoder.data)!
}


//this needs to go to a thread, so it can be executing at background
pub fn proxy_processor(twinid u32, proxyipaddrs []string){
	mut rmb :=rmbclient.new()!
	mut cl:=RMBProxyClient{rmb:rmb,twinid:twinid,proxyipaddrs:proxyipaddrs}
	for proxyipaddr in cl.proxyipaddrs{
		mut wscl:=websocket.new_client(proxyipaddr,ClientOpt{})!
		cl.websocketclients<<wscl
	}
	
}


pub fn (mut cl RMBProxyClient) job_send(action_job rmbclient.ActionJob) ! {
	mut rmb:=rmbp.rmbc
	
	mut ipaddr0:=args.ipaddr
	if ipaddr0==""{
		ipaddr0="localhost"
	}
	ipaddr:=ipaddress.ipaddress_new(ipaddr0)!
	twin:=MyTwin {
		src_twinid: args.src_twinid
		src_rmbids:args.src_rmbids
		ipaddr:ipaddr0
	}
	data:=twin.dumps()!
	rmb.redis.set("rmb.iam",data)!
	rmb.iam=twin

	action_json := action_job.dumps()
	// TODO ecrypt data with public key of twin id who has to execute job
	action_json_encrypted := action_json
	mut data := maps[string]string {}
	data["cmd"] = "job.send"
	data["signature"] = "//TODO!!!"
	data["payload"] = action_json_encrypted

	cl.rpc(data)!
}

