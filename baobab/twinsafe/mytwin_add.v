module twinsafe


pub struct MyTwinAddError {
	Error
mut:
	args        TwinArgs
	error_type MyTwinAddErrorType
	msg string
}

pub enum MyTwinAddErrorType {
	unknown
	double
}

fn (err MyTwinAddError) msg() string {
	if err.error_type == .double {
		return 'Twin was already there:\n${err.args}'
	}
	mut msg := 'Could not add twin.\n${err.msg}\n${err.args}'
	return msg
}

fn (err MyTwinAddError) code() int {
	return int(err.error_type)
}

[params]
pub struct TwinArgs{
pub:
	name string
	id u32
	description string
	privatekey_generate bool
	privatekey string //given in hex or mnemonics
}


// generate a new key is just importing a key with a random seed
// if it exists will return the key which is already there
pub fn (mut ks KeysSafe) mytwin_add(args_ TwinArgs) ! {
	mut args:=args_
	if args.privatekey_generate && args.privatekey.len>0{
		
	}
	mut seed := []u8{}

	// generate a new random seed
	for _ in 0 .. 32 {
		seed << u8(libsodium.randombytes_random()) //TODO: use secp256k1
	}

	//TODO: based on args generate key or add pre-defined key
	//check if hex or mnemonics, then import accordingly

	//use sqlite to store in db, encrypt the private key, symmetric using aes_symmetric 
	//no need to encrypt other properties

	//TODO: use proper error handling with custom error type
}
