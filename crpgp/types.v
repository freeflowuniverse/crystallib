module crpgp

pub fn new_secret_key_param_builder() ?SecretKeyParamsBuilder {
	builder := C.params_builder_new()
	if u64(builder) == 0 {
		construct_error() ?
		return error('')
	}
	return SecretKeyParamsBuilder{
		internal: builder
	}
}

pub fn (b &SecretKeyParamsBuilder) primary_key_id(primary_key_id string) ? {
	if C.params_builder_primary_user_id(b.internal, &char(primary_key_id.str)) != 0 {
		construct_error() ?
	}
}

pub fn (b &SecretKeyParamsBuilder) key_type(key_type C.KeyType) ? {
	if C.params_builder_key_type(b.internal, key_type) != 0 {
		construct_error() ?
	}
}

pub fn (b &SecretKeyParamsBuilder) subkey(subkey SubkeyParams) ? {
	if C.params_builder_subkey(b.internal, subkey.internal) != 0 {
		construct_error() ?
	}
}

pub fn (b &SecretKeyParamsBuilder) build() ?SecretKeyParams {
	params1 := C.params_builder_build(b.internal)
	if u64(params1) == 0 {
		println('failed to build secret key params')
		construct_error() ?
		return error('')
	}
	return SecretKeyParams{
		internal: params1
	}
}

pub fn (s &SecretKeyParams) generate_and_free() ?SecretKey {
	sk := C.params_generate_secret_key_and_free(s.internal)
	if u64(sk) == 0 {
		construct_error() ?
		return error('')
	}
	return SecretKey{
		internal: sk
	}
}

pub fn (s &SecretKey) sign() ?SignedSecretKey {
	ssk := C.secret_key_sign(s.internal)
	if u64(ssk) == 0 {
		construct_error() ?
		return error('')
	}
	return SignedSecretKey{
		internal: ssk
	}
}

pub fn (s &SignedSecretKey) create_signature(data []byte) ?Signature {
	sig := C.signed_secret_key_create_signature(s.internal, &u8(&data[0]), data.len)
	if u64(sig) == 0 {
		construct_error() ?
		return error('')
	}
	return Signature{
		internal: sig
	}
}

pub fn (s &SignedSecretKey) decrypt(data []byte) ?[]byte {
	len := u64(data.len)
	decrypted := C.signed_secret_key_decrypt(s.internal, &u8(&data[0]), &len)
	if u64(decrypted) == 0 {
		construct_error() ?
		return error('')
	}
	return cu8_to_vbytes(decrypted, len)
}

pub fn (s &SignedSecretKey) public_key() ?PublicKey {
	pk := C.signed_secret_key_public_key(s.internal)
	if u64(pk) == 0 {
		construct_error() ?
		return error('')
	}
	return PublicKey{
		internal: pk
	}
}

pub fn (s &SignedSecretKey) to_bytes() ?[]byte {
	len := u64(0)
	ser := C.signed_secret_key_to_bytes(s.internal, &len)
	if u64(ser) == 0 {
		construct_error() ?
		return error('')
	}
	res := cu8_to_vbytes(ser, len)
	C.ptr_free(&u8(ser))
	return res
}

pub fn signed_secret_key_from_bytes(bytes []byte) ?SignedSecretKey {
	ser := C.signed_secret_key_from_bytes(&u8(&bytes[0]), bytes.len)
	if u64(ser) == 0 {
		construct_error() ?
		return error('')
	}
	return SignedSecretKey{
		internal: ser
	}
}

pub fn (s &SignedSecretKey) to_armored() ?string {
	ser := C.signed_secret_key_to_armored(s.internal)
	if u64(ser) == 0 {
		construct_error() ?
		return error('')
	}
	res := unsafe { cstring_to_vstring(ser) }
	C.ptr_free(&u8(ser))
	return res
}

pub fn signed_secret_key_from_armored(s string) ?SignedSecretKey {
	ser := C.signed_secret_key_from_armored(s.str)
	if u64(ser) == 0 {
		construct_error() ?
		return error('')
	}
	return SignedSecretKey{
		internal: ser
	}
}

pub fn (s &Signature) serialize() ?[]byte {
	len := u64(0)
	ser := C.signature_serialize(s.internal, &len)
	if u64(ser) == 0 {
		construct_error() ?
		return error('')
	}
	res := cu8_to_vbytes(ser, len)
	C.ptr_free(ser)
	return res
}

pub fn deserialize_signature(bytes []byte) ?Signature {
	// TODO: is the pointer arith here ok?
	sig := C.signature_deserialize(&u8(&bytes[0]), bytes.len)
	if u64(sig) == 0 {
		construct_error() ?
		return error('')
	}
	return Signature{
		internal: sig
	}
}

pub fn (p &PublicKey) verify(data []byte, sig &Signature) ? {
	ok := C.public_key_verify(p.internal, &u8(&data[0]), data.len, sig.internal)
	if ok != 0 {
		construct_error() ?
		return error('')
	}
}

pub fn (p &PublicKey) sign_and_free(sk SignedSecretKey) ?SignedPublicKey {
	signed := C.public_key_sign_and_free(p.internal, sk.internal)
	if u64(signed) == 0 {
		construct_error() ?
		return error('')
	}
	return SignedPublicKey{
		internal: signed
	}
}

pub fn (s &PublicKey) encrypt(data []byte) ?[]byte {
	len := u64(data.len)
	encrypted := C.public_key_encrypt(s.internal, &u8(&data[0]), &len)
	if u64(encrypted) == 0 {
		construct_error() ?
		return error('')
	}
	return cu8_to_vbytes(encrypted, len)
}

pub fn new_subkey_params_builder() SubkeyParamsBuilder {
	return SubkeyParamsBuilder{
		internal: C.subkey_params_builder_new()
	}
}

pub fn (b &SubkeyParamsBuilder) key_type(key_type C.KeyType) ? {
	if C.subkey_params_builder_key_type(b.internal, key_type) != 0 {
		construct_error() ?
	}
}

pub fn (b &SubkeyParamsBuilder) build() ?SubkeyParams {
	subkey := C.subkey_params_builder_build(b.internal)
	if u64(subkey) == 0 {
		construct_error() ?
		return error('')
	}
	return SubkeyParams{
		internal: subkey
	}
}

pub fn (p &SignedPublicKey) verify(data []byte, sig &Signature) ? {
	ok := C.signed_public_key_verify(p.internal, &u8(&data[0]), data.len, sig.internal)
	if ok != 0 {
		construct_error() ?
		return error('')
	}
}

pub fn (s &SignedPublicKey) encrypt(data []byte) ?[]byte {
	len := u64(data.len)
	encrypted := C.signed_public_key_encrypt(s.internal, &u8(&data[0]), &len)
	if u64(encrypted) == 0 {
		construct_error() ?
		return error('unreachable!')
	}
	return cu8_to_vbytes(encrypted, len)
}

pub fn (s &SignedPublicKey) encrypt_with_any(data []byte) ?[]byte {
	len := u64(data.len)
	encrypted := C.signed_public_key_encrypt_with_any(s.internal, &u8(&data[0]), &len)
	if u64(encrypted) == 0 {
		construct_error() ?
		return error('unreachable!')
	}
	return cu8_to_vbytes(encrypted, len)
}

pub fn (s &SignedPublicKey) to_bytes() ?[]byte {
	len := u64(0)
	ser := C.signed_public_key_to_bytes(s.internal, &len)
	if u64(ser) == 0 {
		construct_error() ?
		return error('')
	}
	res := cu8_to_vbytes(ser, len)
	C.ptr_free(&u8(ser))
	return res
}

pub fn signed_public_key_from_bytes(bytes []byte) ?SignedPublicKey {
	ser := C.signed_public_key_from_bytes(&u8(&bytes[0]), bytes.len)
	if u64(ser) == 0 {
		construct_error() ?
		return error('')
	}
	return SignedPublicKey{
		internal: ser
	}
}

pub fn (s &SignedPublicKey) to_armored() ?string {
	ser := C.signed_public_key_to_armored(s.internal)
	if u64(ser) == 0 {
		construct_error() ?
		return error('')
	}
	res := unsafe { cstring_to_vstring(ser) }
	C.ptr_free(&u8(ser))
	return res
}

pub fn signed_public_key_from_armored(s string) ?SignedPublicKey {
	ser := C.signed_public_key_from_armored(s.str)
	if u64(ser) == 0 {
		construct_error() ?
		return error('')
	}
	return SignedPublicKey{
		internal: ser
	}
}
