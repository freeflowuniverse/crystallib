module mbus

import freeflowuniverse.crystallib.params { Params }
import freeflowuniverse.crystallib.algo.encoder
import freeflowuniverse.crystallib.algo.secp256k1
import time

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
