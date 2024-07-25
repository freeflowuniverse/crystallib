#!/usr/bin/env -S v -n -w -enable-globals run

import freeflowuniverse.crystallib.crypt.crpgp
import freeflowuniverse.crystallib.ui.console

fn test_pgp(ssk crpgp.SignedSecretKey, spk crpgp.SignedPublicKey) ! {
	message := 'these are my secrets\n12345'
	mut sig := ssk.sign_message(message)!
	console.print_debug(sig.to_hex()!)

	if spk.verify_signature(sig, message) {
		console.print_debug('✅ message signed and verified!')
	}
	encrypted := spk.encrypt_from_text(message)!
	decrypted := ssk.decrypt_to_text(encrypted)!
	if message == decrypted {
		console.print_debug('✅ message encrypted and decrypted!')
	}
}

// Test import flow
imported_ssk := crpgp.import_secretkey_from_file('./mykey_private_protected_pgp.asc')!
imported_spk := crpgp.import_publickey_from_file('./mykey_pgp.asc')!
console.print_debug('✅ keys loaded!')
test_pgp(imported_ssk, imported_spk)!

// Test generate cv25519 keys flow
cv25519_ssk := crpgp.generate_key(name: 'mohammed', email: 'mohamed@test.com')!
cv25519_spk := cv25519_ssk.get_signed_public_key()!
console.print_debug('✅ cv25519 keys genetated!')
test_pgp(cv25519_ssk, cv25519_spk)!

// Test generate RSA flow
rsa_ssk := crpgp.generate_key(name: 'mohammed', email: 'mohamed@test.com', key_type: .rsa)!
rsa_spk := rsa_ssk.get_signed_public_key()!
console.print_debug('✅ RSA keys genetated!')
test_pgp(rsa_ssk, rsa_spk)!
