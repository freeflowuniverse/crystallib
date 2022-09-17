module pgp

// import freeflowuniverse.crystallib.builder
import os

[heap]
struct PGPInstance {
mut:
	name   string
	pubkey string
}

fn (mut f PGPFactory) new(name string) ?&PGPInstance {
	mut i := PGPInstance{
		name: name
	}
	f.instances[name] = &i
	return &i
}

fn (mut f PGPFactory) get(name string) ?&PGPInstance {
	if name !in f.instances {
		return error('cannot find pgp instance with name $name')
	}

	return f.instances[name]
}

// sign a piece of content, return signature
fn (f PGPInstance) sign(content string) ?Signature {
}

// encrypt for private usage (is this relevant)
fn (f PGPInstance) encrypt_self(content string) ?CryptData {
}

// encrypt for other person, so they can only decrypt
fn (f PGPInstance) encrypt_other(pubkey Pubkey, content string) ?CryptData {
}

// encrypt for other person, so they can only decrypt
// sign using your own pgp key
fn (f PGPInstance) encrypt_sign_other(pubkey Pubkey, content string) ?CryptData {
}

// verify agains own key
fn (f PGPInstance) verify_self(pubkey Pubkey, signature Signature, content string) ?string {
}

// verify with pub key of other
fn (f PGPInstance) verify_other(pubkey Pubkey, signature Signature, content string) ?string {
}

// decrypt with own key
fn (f PGPInstance) decrypt(content CryptData) ?string {
}

// decrypt with own key and also verify (is counterpart of encrypt_sign_other)
fn (f PGPInstance) decrypt_verify(content CryptData) ?string {
}
