import despiegk.crystallib.crpgp

fn test_pgp (ssk crpgp.SignedSecretKey, spk crpgp.SignedPublicKey) ?{
    message := "these are my secrets\n12345"
    mut sig := ssk.sign_message(message) ?
    println(sig.to_hex() ?)

    if spk.verify_signature(sig, message) {
        println("✅ message signed and verified!")
    }
    encrypted := spk.encrypt_from_text(message) ?
	decrypted := ssk.decrypt_to_text(encrypted) ?
    if message == decrypted {
        println("✅ message encrypted and decrypted!")
    }
}

fn main() {
    // Test import flow
    imported_ssk := crpgp.import_secretkey_from_file("./mykey_private_protected_pgp.asc") ?
    imported_spk := crpgp.import_publickey_from_file("./mykey_pgp.asc") ?
    println("✅ keys loaded!")
    test_pgp(imported_ssk, imported_spk) ?

    // Test generate flow
    generated_ssk := crpgp.generate_key(name: 'mohammed', email: 'mohamed@test.com') ?
    generated_spk := generated_ssk.get_signed_public_key() ?
    println("✅ keys genetated!")
    test_pgp(generated_ssk, generated_spk) ?
}
