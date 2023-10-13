import freeflowuniverse.crystallib.crypt.openssl

fn do() ! {
	// the cert dir will be ~/.openssl/
	mut ossl := openssl.new()!

	k := ossl.get(reset: false)!
	println(k)
	k2 := ossl.get(reset: false)!

	println(k2)

	assert k.md5 == k2.md5

	k3 := ossl.get(reset: true)!

	assert k3.md5 != k2.md5
	println(k)
}

fn main() {
	do() or { panic(err) }
}
