module aes_symmetric

fn test_check() {
	d:=encrypt_str("data","mysecret")
	d2:=decrypt_str(d,"mysecret")
	assert d2=="data"
}
