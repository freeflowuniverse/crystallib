[translated]
module secp256k1

import encoding.hex
import crypto.sha256

#include "@VMODROOT/secp256k1mod.h"

#flag @VMODROOT/secp256k1mod.o
#flag -lsecp256k1
#flag -DNO_SECP_MAIN
#flag darwin -I/opt/homebrew/include
#flag darwin -L/opt/homebrew/lib

// linux: require libsecp256k1-dev
// macos: require brew install secp256k1

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

struct Secp256k1_signature {
	cctx &C.secp256k1_sign_t
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

fn C.secp256k1_dumps(secp &Secp256k1_t)

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
	C.secp256k1_load_key(s.cctx, key.str)
}

pub fn (s Secp256k1) generate() {
	C.secp256k1_generate_key(s.cctx)
}

pub fn (s Secp256k1) keys() {
	C.secp256k1_dumps(s.cctx)
}

pub fn (s Secp256k1) export() string {
	key := C.secp256k1_export(s.cctx)
	println(key)
	return unsafe { key.vstring() }
}

pub fn (s Secp256k1) sharedkeys(target Secp256k1) []u8 {
	shr := C.secp265k1_shared_key(s.cctx, target.cctx)

	return unsafe { shr.vbytes(32) } // 32 bytes shared key
}

//
// sign (ecdsa) data
// - we force user to pass data to ensure we hash the right way
//   data to ensure signature is valid and safe
//
pub fn (s Secp256k1) sign_data(data []u8) []u8 {
	// hash data
	h256 := sha256.sum(data)
	signature := C.secp256k1_sign_hash(s.cctx, h256.data, h256.len)

	return unsafe { signature.vbytes(64) } // 64 bytes signature
}

// return a hex string of the signature
pub fn (s Secp256k1) sign_data_hex(data []u8) string {
	payload := s.sign_data(data)
	return hex.encode(payload)
}

pub fn (s Secp256k1) sign_str(data string) []u8 {
	return s.sign_data(data.bytes())
}

// return a hex string of the signature
pub fn (s Secp256k1) sign_str_hex(data string) string {
	return s.sign_data_hex(data.bytes())
}

//
// verify a signature
//
pub fn (s Secp256k1) verify_data(signature []u8, data []u8) bool {
	sig := Secp256k1_signature{}
	sig.cctx = C.secp256k1_load_signature(s.cctx, signature.data, signature.len)

	// compute data hash to ensure we do it correctly
	// - do not trust the user, do it ourself -
	h256 := sha256.sum(data)
	valid := C.secp256k1_sign_verify(s.cctx, sig.cctx, h256.data, h256.len)
	if valid == 1 {
		return true
	}

	return false
}

pub fn (s Secp256k1) verify_str(signature []u8, input string) bool {
	return s.verify_data(signature, input.bytes())
}


//
// sign (schnorr) data
// - we force user to pass data to ensure we hash the right way
//   data to ensure signature is valid and safe
//
pub fn (s Secp256k1) schnorr_sign_data(data []u8) []u8 {
	// hash data
	h256 := sha256.sum(data)
	signature := C.secp256k1_schnorr_sign_hash(s.cctx, h256.data, h256.len)

	return unsafe { signature.vbytes(64) } // 64 bytes signature
}

// return a hex string of the signature
pub fn (s Secp256k1) schnorr_sign_data_hex(data []u8) string {
	payload := s.schnorr_sign_data(data)
	return hex.encode(payload)
}

pub fn (s Secp256k1) schnorr_sign_str(data string) []u8 {
	return s.schnorr_sign_data(data.bytes())
}

// return a hex string of the signature
pub fn (s Secp256k1) schnorr_sign_str_hex(data string) string {
	return s.schnorr_sign_data_hex(data.bytes())
}

//
// verify a signature
//
pub fn (s Secp256k1) schnorr_verify_data(signature []u8, data []u8) bool {
	// compute data hash to ensure we do it correctly
	// - do not trust the user, do it ourself -
	h256 := sha256.sum(data)
	valid := C.secp256k1_schnorr_verify(s.cctx, signature.data, signature.len, h256.data, h256.len)
	if valid == 1 {
		return true
	}

	return false
}

pub fn (s Secp256k1) schnorr_verify_str(signature []u8, input string) bool {
	return s.schnorr_verify_data(signature, input.bytes())
}

