module crpgp

struct C.KeyType {}

struct KeyType {
	internal &C.KeyType
}

struct C.PublicKey {}

struct PublicKey {
	internal &C.PublicKey
}

struct C.SecretKey {}

struct SecretKey {
	internal &C.SecretKey
}

struct C.SecretKeyParams {}

struct SecretKeyParams {
	internal &C.SecretKeyParams
}

struct C.SecretKeyParamsBuilder {}

struct SecretKeyParamsBuilder {
	internal &C.SecretKeyParamsBuilder
}

struct C.Signature {}

struct Signature {
	internal &C.Signature
}

struct C.SignedPublicKey {}

struct SignedPublicKey {
	internal &C.SignedPublicKey
}

struct C.SignedPublicSubKey {}

struct SignedPublicSubKey {
	internal &C.SignedPublicSubKey
}

struct C.SignedSecretKey {}

struct SignedSecretKey {
	internal &C.SignedSecretKey
}

struct C.SubkeyParams {}

struct SubkeyParams {
	internal &C.SubkeyParams
}

struct C.SubkeyParamsBuilder {}

struct SubkeyParamsBuilder {
	internal &C.SubkeyParamsBuilder
}

fn C.last_error_length() int
fn C.error_message(&char, int) int
fn C.public_key_verify(&C.PublicKey, &u8, u64, &C.Signature) char
fn C.public_key_encrypt(&C.PublicKey, &u8, &u64) &u8
fn C.public_key_sign_and_free(&C.PublicKey, &C.SignedSecretKey) &C.SignedPublicKey
fn C.public_key_free(&C.PublicKey) char
fn C.secret_key_sign(&C.SecretKey) &C.SignedSecretKey
fn C.secret_key_free(&C.SecretKey) char
fn C.params_generate_secret_key_and_free(&C.SecretKeyParams) &C.SecretKey
fn C.params_builder_new() &C.SecretKeyParamsBuilder
fn C.params_builder_primary_user_id(&C.SecretKeyParamsBuilder, &char) char
fn C.params_builder_key_type(&C.SecretKeyParamsBuilder, C.KeyType) char
fn C.params_builder_subkey(&C.SecretKeyParamsBuilder, &C.SubkeyParams) char
fn C.params_builder_build(&C.SecretKeyParamsBuilder) &C.SecretKeyParams
fn C.params_builder_free(&C.SecretKeyParamsBuilder) char
fn C.signature_serialize(&C.Signature, &u64) &u8
fn C.signature_deserialize(&u8, u64) &C.Signature
fn C.signature_free(&C.Signature) char
fn C.signed_public_key_verify(&C.SignedPublicKey, &u8, u64, &C.Signature) char
fn C.signed_public_key_encrypt(&C.SignedPublicKey, &u8, &u64) &u8
fn C.signed_public_key_encrypt_with_any(&C.SignedPublicKey, &u8, &u64) &u8
fn C.signed_public_key_to_bytes(&C.SignedPublicKey, &u64) &u8
fn C.signed_public_key_from_bytes(&u8, u64) &C.SignedPublicKey
fn C.signed_public_key_to_armored(&C.SignedPublicKey) &char
fn C.signed_public_key_from_armored(&char) &C.SignedPublicKey
fn C.signed_public_key_free(&C.SignedPublicKey) char
fn C.signed_secret_key_public_key(&C.SignedSecretKey) &C.PublicKey
fn C.signed_secret_key_create_signature(&C.SignedSecretKey, &u8, u64) &C.Signature
fn C.signed_secret_key_decrypt(&C.SignedSecretKey, &u8, &u64) &u8
fn C.signed_secret_key_free(&C.SignedSecretKey) char
fn C.signed_secret_key_to_bytes(&C.SignedSecretKey, &u64) &u8
fn C.signed_secret_key_from_bytes(&u8, u64) &C.SignedSecretKey
fn C.signed_secret_key_to_armored(&C.SignedSecretKey) &char
fn C.signed_secret_key_from_armored(&char) &C.SignedSecretKey
fn C.subkey_params_free(&C.SubkeyParams) char
fn C.subkey_params_builder_new() &C.SubkeyParamsBuilder
fn C.subkey_params_builder_key_type(&C.SubkeyParamsBuilder, C.KeyType) char
fn C.subkey_params_builder_free(&C.SubkeyParamsBuilder) char
fn C.subkey_params_builder_build(&C.SubkeyParamsBuilder) &C.SubkeyParams
fn C.ptr_free(&u8) char
