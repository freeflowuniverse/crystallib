module secrets
import freeflowuniverse.crystallib.ui.console

fn test_check() {
	mut box := get(secret: 'mysecret')!

	r := box.encrypt('aaa')!
	console.print_debug(r)
	assert 'aaa' == box.decrypt(r)!

	hex_secret1 := hex_secret()!
	console.print_debug(hex_secret1)
	console.print_debug(hex_secret1.len)
	assert hex_secret1.len == 24

	openssl_hex_secret1 := openssl_hex_secret()!

	console.print_debug(openssl_hex_secret1)
	console.print_debug(openssl_hex_secret1.len)
	assert openssl_hex_secret1.len == 64

	openssl_base64_secret1 := openssl_base64_secret()!

	console.print_debug(openssl_base64_secret1)
	console.print_debug(openssl_base64_secret1.len)
	assert openssl_base64_secret1.len == 44
}
