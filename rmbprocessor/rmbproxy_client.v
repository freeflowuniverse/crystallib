
module rmbprocessor

import freeflowuniverse.crystallib.rmbclient
import freeflowuniverse.crystallib.encoder

import log
import net.websocket

//client to the rmb proxy
pub struct RMBProxyClient {
pub mut:
	twinid u32
	proxyipaddrs []string
	websocketclients []&websocket.Client //in reality its not string, its webdav clients, is more than 1
	websocketclient_active u8 //the current webdavclient which is being used, the one which is active
	logger &log.Logger
	ch_receive chan rmbclient.ActionJob
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
	data["dsttwinid"] = action_job.twinid
	data["signature"] = "//TODO!!!"
	data["payload"] = action_json_encrypted

	cl.rpc(data)!
}

fn (mut cl RMBProxyClient) sending(ch chan rmbclient.ActionJob) {
	for !ch_send.closed {
		if select {
    		job := <-ch_send {
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

fn (mut cl RMBProxyClient) listening(ch chan rmbclient.ActionJob) {
	cl.ch_receive = ch
	for {
		mut websocketclient := cl.websocketclients[cl.websocketclient_active]
		if websocketclient.state != .open {
			websocketclient.connect() or {
				// failed to connect lets try the second one
				cl.logger.error("Failed to connect to ${cl.proxyipaddrs[cl.websocketclient_active]}")
				cl.next_websocketclient()
				continue
			}
		}

		// lets start listening and process incoming messages in a new thread
		// we wait for the thread to return which then means we have lost connection
		// so try again in the next iteration (if needed try the next websocketclient)
		websocketclient.listen() or {
			cl.logger.error("Lost connection to RMBProxy ${cl.proxyipaddrs[cl.websocketclient_active]}")
		}
	}
}

fn (mut cl RMBProxyClient) on_message(mut client websocket.Client, msg &websocket.Message) ! {
	// Process messages received from Proxy
	// if its job pass it through the channel to the processor
}

// starts listening and sending messages received through channels to the RMBProxy 
pub fn (mut cl RMBProxyClient) run(ch_send chan rmbclient.ActionJob, ch_receive chan rmbclient.ActionJob) ! {
	t_listen := spawn cl.sending(ch_send)
	t_sending := spawn cl.listening(ch_receive)

	t_listen.wait()
	t_sending.wait()
}

pub fn new_rmbproxyclient(twinid u32, proxyipaddrs []string, logger &log.Logger) !RMBProxyClient {
	mut rmbpc := RMBProxyClient {
		twinid: twinid,
		proxyipaddrs: proxyipaddrs
		logger: unsafe { logger }
	}
	for proxyipaddr in rmbpc.proxyipaddrs {
		mut wscl := websocket.new_client(proxyipaddr, websocket.ClientOpt{}) or {
			return error("failed to create client for $proxyipaddr: $err")
		}
		wscl.on_message(rmbpc.on_message)
		rmbpc.websocketclients << wscl
	}
	return rmbpc
}