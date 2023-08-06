module twinsafe

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.algo.secp256k1

pub struct MyTwinGetError {
	Error
mut:
	args        TwinGetArgs
	error_type MyTwinGetErrorType
	msg string
}

pub enum MyTwinGetErrorType {
	notfound
	double
}

fn (err MyTwinGetError) msg() string {
	if err.error_type == .double {
		return 'More than 1 twin found:\n${err.args}'
	}
	mut msg := 'Could not get twin.\n${err.msg}\n${err.args}'
	return msg
}

fn (err MyTwinGetError) code() int {
	return int(err.error_type)
}

[params]
pub struct MyTwinGetArgs{
pub:
	name string
	id u32
}


//this is me, my representation
pub struct MyTwin{
pub:
	name string
	id u32
	description string
	privkey Secp256k1 //to be used for signing, verifying, only to be filled in when private key	
}

//I can have more than 1 mytwin, ideal for testing as well
pub fn (mut ks KeysSafe) mytwin_get(args MyTwinGetArgs) !MyTwin {


	//use sqlite to get info (do query)
	//decrypt the private key
}


//use my private keyto sign data, important before sending
fn (mut twin MyTwin) sign (data []u8 )![]u8 {

}