module secrets

import rand
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.crypt.aes_symmetric
import crypto.md5
import regex
import os
import encoding.base64

// will use our secret as configured for the hero to encrypt
pub fn (mut b SecretBox) encrypt(txt string) !string {
	d := aes_symmetric.encrypt_str(txt, b.secret)
	return base64.encode_str(d)
}

pub fn (mut b SecretBox) decrypt(txt string) !string {
	txt2 := base64.decode_str(txt)
	return aes_symmetric.decrypt_str(txt2, b.secret)
}
