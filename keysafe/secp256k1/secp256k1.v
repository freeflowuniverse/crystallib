[translated]
module secp256k1

#include "@VMODROOT/secp256k1mod.h"

#flag @VMODROOT/secp256k1mod.o
#flag -lsecp256k1 -DNO_SECP_MAIN

//
// struct definitions
//
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
pub: // FIXME
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

struct Secp256k1 {
	cctx &Secp256k1_t
}


//
// prototypes
//
fn C.secp256k1_new() &Secp256k1_t

fn C.secp256k1_schnorr_verify(secp &Secp256k1_t, signature &u8, siglen usize, hash &u8, hashlen usize) int

fn C.secp256k1_schnorr_sign_hash(secp &Secp256k1_t, hash &u8, length usize) &u8

fn C.secp256k1_sign_verify(secp &Secp256k1_t, signature &Secp256k1_sign_t, hash &u8, length usize) int

fn C.secp256k1_sign_free(signature &Secp256k1_sign_t) 

fn C.secp256k1_load_signature(secp &Secp256k1_t, serialized &u8, length usize) &Secp256k1_sign_t

fn C.secp256k1_sign_hash(secp &Secp256k1_t, hash &u8, length usize) &u8

fn C.secp265k1_shared_key(private &Secp256k1_t, public &Secp256k1_t) &u8

fn C.secp256k1_load_key(secp &Secp256k1_t, key &u8) int

fn C.secp256k1_free(secp &Secp256k1_t)

fn C.secp256k1_export(secp &Secp256k1_t) &u8

fn C.secp256k1_generate_key(secp &Secp256k1_t) int

//
// v implementation
//
pub fn new() Secp256k1 {
	secp := Secp256k1{}
	secp.cctx = C.secp256k1_new()

	return secp
}

pub fn (s Secp256k1) load(key string) {
	println("load")
}

pub fn (s Secp256k1) generate() {
	C.secp256k1_generate_key(s.cctx)
}

pub fn (s Secp256k1) keys() {
    println(s.cctx.seckey)
    println(s.cctx.compressed)
    println(s.cctx.xcompressed)
}

pub fn (s Secp256k1) export() string {
	key := C.secp256k1_export(s.cctx)
	println(key)
	return key.vstring()
}


