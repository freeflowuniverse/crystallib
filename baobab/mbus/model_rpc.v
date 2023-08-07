module mbus

import freeflowuniverse.crystallib.params { Params }
import freeflowuniverse.crystallib.algo.encoder
import freeflowuniverse.crystallib.algo.secp256k1
import time

//mycelium rpc message = a reliable rpc message  (remote procedure call)
pub struct RPCMessage {
pub mut:
	rpc_id		  	  u32    // unique on the source twin
	twinid_source     u32    // which twin has asked to get something
	twinid_exec       u32    // which twins need to receive and execute
	circle			  u32   //unique on the exec twins (need to exist on each twin which needs to execute)
	action		string  	// e.g. cloud.vm_create
	msg			[]u8	//bytestr
	time 		 u64    //time when it was send
	timeout      u16    //seconds for timeout
	signature   []u8    //signature using private key on source twin
}

//does encoding, the last 64 bytes are for the signature
pub fn (mut msg RPCMessage) encode( crypto secp256k1.Secp256k1) ![]u8 {
	mut e := encoder.new()
	e.add_u32(msg.rpc_id)
	e.add_u32(msg.twinid_source)	
	e.add_u32(msg.twinid_exec)
	e.add_u32(msg.circle)
	e.add_string(msg.action)
	e.add_bytes(msg.msg)
	e.add_u64(msg.time)
	e.add_u16(msg.timeout)
	e.data //is the encoded data
	//TODO: sign using secp256k1 (crypto) and store signature in e.signature
	return e.data
}

//go from binary form to RPCmessage
pub fn decode([]u8) !RPCMessage {

	mut e := encoder.new()
	//TODO:

	return RPCMessage{}
}


//verify using a pubkey
pub fn (mut msg RPCMessage) verify(pubkey u8[]) []u8 {
	//TODO:
}

//this is message as sent by executor, who acknowledges that 
pub struct ExecutorAcceptMessage {
pub mut:
	rpc_id		  	  u32    // unique on the source twin
	hash			  []u8   // md5 of RPCMessage
	twinid_source     u32    // which twin has asked to get something (source of rpc)
	twinid_exec       u32    // id of the twin which accepts the message for execution and payment
	twinid_receive	  u32    // id of twin which needs to receive the acceptance
	signature   []u8    	 // signature using private key on exec twin for md5 of RPCMessage
}

pub struct ResultMessage {
pub mut:
	rpc_id		  	  u32    // unique on the source twin
	hash			  []u8   // md5 of RPCMessage
	twinid_source     u32    // which twin has asked to get something (source of rpc)
	twinid_exec       u32    // id of the twin which accepts the message for execution and payment
	twinid_receive	  u32    // id of twin which needs to receive the result
	msg			[]u8		 // the result
	signature   []u8    	 // signature using private key on exec twin for md5 of RPCMessage
}
