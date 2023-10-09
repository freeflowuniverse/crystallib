module openssl

import crypto.md5

// give md5 hash of key (concatenate the key+cert)
pub fn (mut key OpenSSLKey) hexhash() !string {
	mut out := ''
	out += key.path_key.read()!
	out += key.path_cert.read()!

	res := md5.hexhash(out)

	key.md5 = res

	return res
}
