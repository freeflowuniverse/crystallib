[translated]
module secp256k1

#include "@VMODROOT/secp256k1mod.h"

#flag @VMODROOT/secp256k1mod.o
#flag -lsecp256k1

struct Secp256k1_pubkey { 
	data [64]u8
}

struct Secp256k1_xonly_pubkey {
	data [64]u8
}

struct Secp256k1_ecdsa_signature { 
	data [64]u8
}

struct Secp256k1_keypair { 
	data [96]u8
}

struct Secp256k1_t { 
	kntxt &C.secp256k1_context
	seckey &u8
	compressed &u8
	pubkey Secp256k1_pubkey
	xcompressed &u8
	xpubkey Secp256k1_xonly_pubkey
	keypair Secp256k1_keypair
}

struct Secp256k1_sign_t { 
	sig Secp256k1_ecdsa_signature
	serialized &u8
	length usize
}
fn C.secp256k1_new() &Secp256k1_t

pub fn new() &Secp256k1_t {
	return C.secp256k1_new()
}

fn C.secp256k1_free(secp &Secp256k1_t) 

pub fn free(secp &Secp256k1_t)  {
	C.secp256k1_free(secp)
}

fn C.secp256k1_generate_key(secp &Secp256k1_t) int

pub fn generate_key(secp &Secp256k1_t) int {
	return C.secp256k1_generate_key(secp)
}

fn C.secp265k1_shared_key(private &Secp256k1_t, public &Secp256k1_t) &u8

pub fn secp265k1_shared_key(private &Secp256k1_t, public &Secp256k1_t) &u8 {
	return C.secp265k1_shared_key(private, public)
}

fn C.secp256k1_sign_hash(secp &Secp256k1_t, hash &u8, length usize) &u8

pub fn sign_hash(secp &Secp256k1_t, hash &u8, length usize) &u8 {
	return C.secp256k1_sign_hash(secp, hash, length)
}

fn C.secp256k1_load_signature(secp &Secp256k1_t, serialized &u8, length usize) &Secp256k1_sign_t

pub fn load_signature(secp &Secp256k1_t, serialized &u8, length usize) &Secp256k1_sign_t {
	return C.secp256k1_load_signature(secp, serialized, length)
}

fn C.secp256k1_sign_free(signature &Secp256k1_sign_t) 

pub fn sign_free(signature &Secp256k1_sign_t)  {
	C.secp256k1_sign_free(signature)
}

fn C.secp256k1_sign_verify(secp &Secp256k1_t, signature &Secp256k1_sign_t, hash &u8, length usize) int

pub fn sign_verify(secp &Secp256k1_t, signature &Secp256k1_sign_t, hash &u8, length usize) int {
	return C.secp256k1_sign_verify(secp, signature, hash, length)
}

fn C.secp256k1_schnorr_sign_hash(secp &Secp256k1_t, hash &u8, length usize) &u8

pub fn schnorr_sign_hash(secp &Secp256k1_t, hash &u8, length usize) &u8 {
	return C.secp256k1_schnorr_sign_hash(secp, hash, length)
}

fn C.secp256k1_schnorr_verify(secp &Secp256k1_t, signature &u8, siglen usize, hash &u8, hashlen usize) int

pub fn schnorr_verify(secp &Secp256k1_t, signature &u8, siglen usize, hash &u8, hashlen usize) int {
	return C.secp256k1_schnorr_verify(secp, signature, siglen, hash, hashlen)
}

pub fn test() {
	x := "hello"
}
