module twinsafe


pub struct OtherTwinAddError {
	Error
mut:
	args        TwinArgs
	error_type OtherTwinAddErrorType
	msg string
}

pub enum OtherTwinAddErrorType {
	unknown
	double
}

fn (err OtherTwinAddError) msg() string {
	if err.error_type == .double {
		return 'Twin was already there:\n${err.args}'
	}
	mut msg := 'Could not add twin.\n${err.msg}\n${err.args}'
	return msg
}

fn (err OtherTwinAddError) code() int {
	return int(err.error_type)
}

[params]
pub struct OtherTwinArgs{
pub:
	name string
	id u32
	description string
	publickey string //given in hex
	conn_type TwinConnectionType 
	addr string      //
}

enum TwinConnectionType{
	ipv6
	ipv4
	redis 
}

// generate a new key is just importing a key with a random seed
// if it exists will return the key which is already there
pub fn (mut ks KeysSafe) othertwin_add(args_ TwinArgs) ! {
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
