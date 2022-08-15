module twinclient2

import net.websocket
import rand

type MessageChannel chan websocket.Message{}

struct TwinClient {
	pub:
		ws websocket.Client
	pub mut:
		channels  []MessageChannel
}

pub fn init_client (ws websocket.Client) TwinClient {
	TwinClient {
		ws: ws
		channels: map[string]MessageChannel{}
	}
}

fn (tcl GridClient) invoke(functionPath string, args map[string]string) string {  
       id = rand.uuid_v4()
       channel = MessageChannel{}
       tcl.channels[id] = channel
	   payload = {id:id, fn: "invoke", invokeargs:{functionPath, args}}
	   // construct the message `msg`
       tcl.ws.send_message(msg)
       res =  tcl.wait(id)   
       return res
}

fn (tcl GridClient) wait(id string) string {
		channel = tcl.channels[id]
		res <-channel
		channel.close()
		tcl.channels.delete(id)
		return res
}
