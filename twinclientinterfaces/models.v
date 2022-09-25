module twinclientinterfaces
import net.websocket as ws
import net.http



pub struct WSTwinClient{
	pub mut:
		ws       	ws.Client
		channels 	map[string]chan Message
}

pub struct BlockChainModel{
pub:
	name string
	public_key string
	blockchain_type string
}

struct TwinClient {
	pub mut:
		transport ITwinTransport
}

pub struct HttpTwinClient{
	pub mut:
		url string
		method http.Method
		header http.Header
		data string
}

pub struct RmbTwinClient{
}

pub struct Message {
	pub:
		id string
		event string
		data string
}

pub struct InvokeRequest {
mut:
	function string
	args string
}

// interfaces
pub interface ITwinTransport {
	mut:
		send(functionPath string, args string)? Message
	// wait(id string, timeout u32)? CustomResponse
}

// // types...
pub type TwinClientType = WSTwinClient | RmbTwinClient | HttpTwinClient
pub type RawMessage = ws.Message
