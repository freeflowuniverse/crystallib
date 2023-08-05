module twinsafe

import freeflowuniverse.crystallib.pathlib
// import freeflowuniverse.crystallib.mnemonic // buggy for now
import encoding.hex
import libsodium
import json
import os
import db.sqlite

pub struct TwinAddError {
	Error
mut:
	args        TwinArgs
	error_type ErrorType
	msg string
}

pub enum ErrorType {
	double
}

fn (err TwinAddError) msg() string {
	if err.error_type == .double {
		return 'Twin was already there:\n${err.args}'
	}
	mut msg := 'Could not add twin.\n${err.msg}\n${err.args}'
	return msg
}

fn (err TwinAddError) code() int {
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
// pub fn (mut ks KeysSafe) add(args_ TwinArgs) ! {
// 	mut args:=args_
// 	if args.privatekey_generate && args.privatekey.len>0{
		
// 	}
// 	if !ks.exists(args.name, id:args.id, publickey:args.publickey){
// 	}
// 	mut k:= ks.get(args.name)!

// 	mut seed := []u8{}

// 	// generate a new random seed
// 	for _ in 0 .. 32 {
// 		seed << u8(libsodium.randombytes_random())
// 	}

// 	return ks.key_import_add(args.name, seed)
// }
