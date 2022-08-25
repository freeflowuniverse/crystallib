module twinclient2

import net.websocket as ws
import json
import rand
import time

pub const factory = Factory{}

struct Factory {
	mut:
	clients map[string]TwinClient
}

pub struct TwinClient {
pub mut:
	ws       	ws.Client
	channels 	map[string]chan Message
	contracts	Contracts
	capacity 	Capacity
	qsfs_zdbs	QsfsZdbs
	machines	Machines
	gateways	GateWays
	algorand  	Algorand
	kvstore		KVstore
	tfchain  	TfChain
	stellar 	Stellar
	twins	 	Twins
	k8s			K8S
	zos 		Zos
}

pub type ResultHandler = fn (Message)

pub type RawMessage = ws.Message

pub fn init_client(mut ws ws.Client) TwinClient {
	mut f :=  twinclient2.factory
	if ws.id in f.clients {
		return twinclient2.factory.clients[ws.id]
	}

	mut tcl := TwinClient{
		ws: ws
		channels: map[string]chan Message{}
	}

	// Initialize the TwinClient modules.
	tcl.contracts	= new_contracts(mut tcl)
	tcl.qsfs_zdbs 	= new_qsfs_zdbs(mut tcl)
	tcl.machines 	= new_machines(mut tcl)
	tcl.capacity 	= new_capacity(mut tcl)
	tcl.gateways	= new_gateways(mut tcl)
	tcl.algorand 	= new_algorand(mut tcl)
	tcl.kvstore 	= new_kvstore(mut tcl)
	tcl.tfchain 	= new_tfchain(mut tcl)
	tcl.stellar 	= new_stellar(mut tcl)
	tcl.twins 		= new_twins(mut tcl)
	tcl.k8s 		= new_k8s(mut tcl)
	tcl.zos 		= new_zos(mut tcl)

	ws.on_message(fn [mut tcl] (mut c ws.Client, raw_msg &RawMessage) ? {
		if raw_msg.payload.len == 0 {
			return
		}

		msg := json.decode(Message, raw_msg.payload.bytestr()) or {
			eprintln('cannot decode message payload')
			return
		}

		if msg.event == 'invoke_result' {
			println('processing invoke response: $msg')
			channel := tcl.channels[msg.id] or {
				eprintln('channel for $msg.id is not there')
				return
			}

			println('pushing msg to channel: $msg.id')
			channel <- msg
		}
	})
	ws.on_close(fn [mut f] (mut c ws.Client, code int, reason string) ?{
		f.clients.delete(c.id)
	})
	f.clients[ws.id] = tcl
	return tcl
}

pub fn (mut tcl TwinClient) send(functionPath string, args string) ?Message {
	id := rand.uuid_v4()

	channel := chan Message{}
	tcl.channels[id] = channel

	mut req := InvokeRequest{}
	req.function = functionPath
	req.args = args

	payload := json.encode(Message{
		id: id
		event: 'invoke'
		data: json.encode(req)
	}).bytes()

	tcl.ws.write(payload, .text_frame)?
	println('waiting for result...')
	return tcl.wait(id, 20) // won't wait more than 20 seconds
}

fn (mut tcl TwinClient) wait(id string, timeout u32) ?Message {
	if channel := tcl.channels[id] {
		select {
			res := <-channel {
				channel.close()
				tcl.channels.delete(id)
				return res
			}
			timeout * time.second {
				er := "requets with id $id was timed out!"
				channel.close()
				tcl.channels.delete(id)
				return error(er)
			}
		}
		
		
	}

	return error('wait channel of $id is not present')
}
