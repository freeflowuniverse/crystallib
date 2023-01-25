module keysafe

import crypto.aes
import crypto.md5
import crypto.cipher

fn padded_length(source []u8, blocksize int) int {
	if (source.len % blocksize) == 0 {
		return source.len
	}

	return ((source.len / blocksize) + 1) * blocksize
}

pub fn symmetric_encrypt_blocks(data []u8, secret string) []u8 {
	key := md5.hexhash(secret)

	// initialize aes with md5 of the secret (always same length)
	ae := aes.new_cipher(key.bytes())

	// use null iv
	iv := []u8{len: ae.block_size}
	mut cb := cipher.new_cbc(ae, iv)

	// add padding to data
	length := padded_length(data, ae.block_size)

	mut padded := []u8{len: length}
	copy(mut padded, data)

	// encrypt blocks
	mut destination := []u8{len: length}
	cb.encrypt_blocks(mut destination, padded)

	return destination
}

pub fn symmetric_decrypt_blocks(data []u8, secret string) []u8 {
	key := md5.hexhash(secret)

	// initialize aes with md5 of the secret (always same length)
	ae := aes.new_cipher(key.bytes())

	// use null iv
	iv := []u8{len: ae.block_size}
	mut cb := cipher.new_cbc(ae, iv)

	// encrypt blocks
	mut destination := []u8{len: data.len}
	cb.decrypt_blocks(mut destination, data)

	return destination
}
