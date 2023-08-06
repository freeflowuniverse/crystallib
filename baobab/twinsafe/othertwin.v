module twinsafe

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.algo.secp256k1
import freeflowuniverse.crystallib.baobab.mbus

pub struct OtherTwinGetError {
	Error
mut:
	args        OtherTwinGetArgs
	error_type OtherTwinGetErrorType
	msg string
}

pub enum OtherTwinGetErrorType {
	notfound
	double
}

fn (err OtherTwinGetError) msg() string {
	if err.error_type == .double {
		return 'More than 1 twin found:\n${err.args}'
	}
	mut msg := 'Could not get twin.\n${err.msg}\n${err.args}'
	return msg
}

fn (err OtherTwinGetError) code() int {
	return int(err.error_type)
}

[params]
pub struct OtherTwinGetArgs{
pub:
	name string
	id u32
}

pub struct OtherTwin{
pub:
	name string
	id u32
	description string
	pubkey ... //TODO: how to do the pubkey, what is form of that?
	conn_type TwinConnectionType 
	addr string      //ipv4 or ipv6 or redis connection string
}

enum TwinConnectionType{
	ipv6
	ipv4
	redis 
}


//other twins, are remote twins
//they have the info as required to connect to them
pub fn (mut ks KeysSafe) othertwin_get(args OtherTwinGetArgs) !OtherTwin {


	//use sqlite to get info (do query)
}

//send message to this other twin
pub fn (mut twin OtherTwin) send (mbus.RPCMessage)!{

	//TODO: convert to binary (means signature is part of it too)
	//TODO: give to mbus to send

}


//receive info from mbus, if anything in there
pub fn (mut twin OtherTwin) receive ()!mbus.RPCMessage{

	//TODO: receive data from mbus for this twin
	//TODO: verify the data which comes back over mbus with twin.verify... 
	//TODO: probably need to use ? as return, so its optional result

}

//verify the received data from the mbus and make sure signature is ok
fn (mut twin OtherTwin) verify (data []u8, signature []u8)! {

}