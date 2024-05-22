module secrets

fn test_check() {
	mut box := get(secret: 'mysecret')!

	r := box.encrypt('aaa')!
	println(r)
	assert 'aaa' == box.decrypt(r)!

	hex_secret1 := hex_secret()!
	println(hex_secret1)
	println(hex_secret1.len)
	assert hex_secret1.len == 24

	openssl_hex_secret1 := openssl_hex_secret()!

	println(openssl_hex_secret1)
	println(openssl_hex_secret1.len)
	assert openssl_hex_secret1.len == 64

	openssl_base64_secret1 := openssl_base64_secret()!

	println(openssl_base64_secret1)
	println(openssl_base64_secret1.len)
	assert openssl_base64_secret1.len == 44
}
