module twinclientinterfaces
import net.websocket as ws
import json
import time
import rand


struct Factory {
	mut:
		clients map[string]WSTwinClient
}

pub const factory = Factory{}

pub fn (mut tcl WSTwinClient)init(mut ws_client ws.Client)? WSTwinClient {
	mut f := factory

	if tcl.ws.id in f.clients {
		println("ana hena")
		return factory.clients[tcl.ws.id]
	}
	tcl.ws = ws_client
	tcl.channels = map[string]chan Message{}
	ws_client.on_message(fn [mut tcl] (mut c ws.Client, raw_msg &RawMessage) ? {
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

	ws_client.on_close(fn [mut f] (mut c ws.Client, code int, reason string) ?{
		f.clients.delete(c.id)
	})
	f.clients[tcl.ws.id] = tcl
	return tcl
}

pub fn (mut tcl WSTwinClient)send(functionPath string, args string)? Message {
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
	return tcl.wait(id, 5) // won't wait more than 300 seconds
}

fn (mut tcl WSTwinClient) wait(id string, timeout u32)? Message {
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
