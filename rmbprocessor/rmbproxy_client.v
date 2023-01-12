
module rmbprocessor

import freeflowuniverse.crystallib.rmbclient
import freeflowuniverse.crystallib.encoder

import log
import net.websocket

//client to the rmb proxy
pub struct RMBProxyClient {
pub mut:
	rmbc rmbclient.RMBClient
	twinid u32
	proxyipaddrs []string
	websocketclients []&websocket.Client //in reality its not string, its webdav clients, is more than 1
	websocketclient_active u8 //the current webdavclient which is being used, the one which is active
	logger &log.Logger
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
		mut websocketclient := cl.websocketclients[cl.websocketclient_active]
		if websocketclient.state != .open {
			websocketclient.connect() or {
				// failed to connect lets try the second one
				cl.logger.error("failed to connect to ${cl.proxyipaddrs[cl.websocketclient_active]}")
				cl.next_websocketclient()
				nbr_tries += 1
				continue
			}
		}
		written_length := websocketclient.write(data, .binary_frame) or {
			// failed writing lets try the next one
			cl.logger.error("failed to send to ${cl.proxyipaddrs[cl.websocketclient_active]}")
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

pub fn (mut cl RMBProxyClient) job_send(action_job rmbclient.ActionJob) ! {
	cl.logger.info("Sending job to RMBProxy: $action_job")
	action_json := action_job.dumps()
	// TODO ecrypt data with public key of twin id who has to execute job
	action_json_encrypted := action_json
	mut data := map[string]string {}
	data["cmd"] = "job.send"
	data["signature"] = "//TODO!!!"
	data["payload"] = action_json_encrypted

	cl.rpc(data)!
}

pub fn (mut cl RMBProxyClient) run(ch chan rmbclient.ActionJob) ! {
	for !ch.closed {
		if select {
    		job := <-ch {
				// channel is ready and has received a job
				cl.job_send(job) or {
					cl.logger.error("Failed to send job: $err")
				}
    		}
		}{} else {
			// need to add else statement to proceed directly if channel is not ready
			// this could be due to channel that is closed too but the next for loop will break then
		}
	}
}


//this needs to go to a thread, so it can be executing at background
pub fn new_rmbproxyclient(twinid u32, proxyipaddrs []string, logger &log.Logger) !RMBProxyClient {
	mut rmbc := rmbclient.new()!
	mut rmbpc := RMBProxyClient { 
		rmbc: &rmbc,
		twinid: twinid,
		proxyipaddrs: proxyipaddrs
		logger: unsafe { logger }
	}
	for proxyipaddr in rmbpc.proxyipaddrs {
		mut wscl := websocket.new_client(proxyipaddr, websocket.ClientOpt{}) or {
			return error("failed to create client for $proxyipaddr: $err")
		}
		rmbpc.websocketclients << wscl
	}
	return rmbpc
}