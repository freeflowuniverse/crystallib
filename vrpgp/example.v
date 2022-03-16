import core

fn main() {
	mut secret_key := core.generate_key()?
	// --- serialization deserialization ---
	mut armored := secret_key.to_armored()?
	println("signed secret key")
	println(armored)
	secret_key = core.signed_secret_key_from_armored(
		armored
	)?
	// -------------------------------------
	mut spk := secret_key.public_key()?.sign_and_free(secret_key)?
	// --- serialization deserialization ---
	armored = spk.to_armored()?
	println("signed public key")
	println(armored)
	spk = core.signed_public_key_from_armored(armored)?
	// -------------------------------------
	mut sig := secret_key.create_signature(core.str_to_bytes("omar"))?
	sig = core.deserialize_signature(sig.serialize()?)?
	spk.verify(core.str_to_bytes("omar"), sig)?
	println("verification succeeded")
	spk.verify(core.str_to_bytes("khaled"), sig) or {
		print("verification failed as expected for invalid sig:")
		println(err)
	}

	encrypted := spk.encrypt_with_any(core.str_to_bytes("omar\0"))?
	decrypted := secret_key.decrypt(encrypted)?
	print("decrypted (should be omar): ")
	println(unsafe { cstring_to_vstring(&char(&decrypted[0])) })
}