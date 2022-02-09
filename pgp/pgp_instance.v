module pgp

// import builder
import os


[heap]
struct PGPInstance {
mut:
	name string
	pubkey string
}


fn (mut f PGPFactory) new (name string) ?&PGPInstance{
	mut i := PGPInstance{name:name}
	f.instances[name] = &i
	return &i
}

fn (mut f PGPFactory) get (name string) ?&PGPInstance{
	if ! (name in f.instances){
		return error("cannot find pgp instance with name $name")
	}

	return f.instances[name]

}



fn (f PGPInstance) sign (content string) ?string{
}

//encrypt for private usage (is this relevant)
fn (f PGPInstance) encrypt_self (content string) ?string{
}

//encrypt for other person, so they can only decrypt
fn (f PGPInstance) encrypt_other (pubkey string, content string) ?string{
}

//encrypt for other person, so they can only decrypt
//sign using your own pgp key
fn (f PGPInstance) encrypt_sign_other (pubkey string, content string) ?string{
}

//verify agains own key
fn (f PGPInstance) verify_self (pubkey string, content string) ?string{
}

//verify with pub key of other
fn (f PGPInstance) verify_other (pubkey string, content string) ?string{
}


//decrypt with own key
fn (f PGPInstance) decrypt (content string) ?string{
}


//decrypt with own key and also verify (is counterpart of encrypt_sign_other)
fn (f PGPInstance) decrypt_verify (content string) ?string{
}
