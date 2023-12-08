module aes_symmetric

import crypto.aes
import crypto.md5
import crypto.cipher
import encoding.binary as bin

fn padded_length(source []u8, blocksize int) int {
	if (source.len % blocksize) == 0 {
		return source.len
	}

	return ((source.len / blocksize) + 1) * blocksize
}

pub fn encrypt_str(data string, secret string) string {
	mut d:=encrypt(data.bytes(),secret)
	return d.bytestr()
}

pub fn encrypt(data []u8, secret string) []u8 {
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

	destination << []u8{len: 2}
	// we add the len of the padding at end
	bin.little_endian_put_u16_end(mut destination, u16(length - data.len))

	return destination
}

pub fn decrypt_str(data string, secret string) string {
	mut d := decrypt(data.bytes(),secret)
	return d.bytestr()
}


pub fn decrypt(data []u8, secret string) []u8 {
	key := md5.hexhash(secret)

	lenextra := bin.little_endian_u16_end(data)
	data2 := data[0..data.len - 2]

	// initialize aes with md5 of the secret (always same length)
	ae := aes.new_cipher(key.bytes())

	// use null iv
	iv := []u8{len: ae.block_size}
	mut cb := cipher.new_cbc(ae, iv)

	// decrypt blocks
	mut destination := []u8{len: data2.len}
	cb.decrypt_blocks(mut destination, data2)

	return destination[0..destination.len - lenextra]
}
