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
	ws       ws.Client
	channels map[string]chan Message
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
	return tcl.wait(id)
}

fn (mut tcl TwinClient) wait(id string) ?Message {
	if channel := tcl.channels[id] {
		res := <-channel
		channel.close()
		tcl.channels.delete(id)
		return res
	}

	return error('wait channel of $id is not present')
}
