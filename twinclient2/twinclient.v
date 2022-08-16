module twinclient2

import net.websocket
import rand


struct TwinClient {
	pub:
		ws websocket.Client
	pub mut:
		channels  map[string]chan websocket.Message
}

pub fn init_client (ws websocket.Client) TwinClient {
	return TwinClient {
		ws: ws
		channels: map[string]chan websocket.Message{}
	}
}

fn (mut tcl TwinClient) invoke(functionPath string, args map[string]string) string {  
       id := rand.uuid_v4()
       channel := chan websocket.Message{}
       tcl.channels[id] = channel
	   payload := {"id":id, "fn": "invoke", "invokeargs":{functionPath, args}}
	   // construct the message `msg` from the payload
       tcl.ws.send_message(msg)
       res :=  tcl.wait(id)   
       return res
}

fn (mut tcl TwinClient) wait(id string) websocket.Message {
		channel := tcl.channels[id]
		res := <-channel
		channel.close()
		tcl.channels.delete(id)
		return res
}
