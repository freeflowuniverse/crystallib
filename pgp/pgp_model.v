module pgp

// import builder
import os

pub struct Pubkey {
mut:
	pubkey string
}

// validate if pubkey is valid
fn (mut pubkey Pubkey) validate() bool {
}

pub struct Signature {
mut:
	signature string
}

// validate if Signature is valid
fn (mut signature Signature) validate() bool {
}

pub struct CryptData {
mut:
	data      string
	signature Signature
}

// validate if CryptData is valid
fn (mut data CryptData) validate() bool {
}

fn (mut data CryptData) verify() {
}

// TODO: what are the methods we need?
