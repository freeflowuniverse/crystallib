import core
import os
import encoding.hex

//PublicKey
struct PublicKey {
    core.SignedPublicKey
}

fn (self &PublicKey) verify_signature(sig Signature, message string) bool {
    self.verify(message.bytes(), sig.Signature) or {
        return false
    }
    return true
}

fn (self &PublicKey) encrypt_from_text(message string) ?[]byte {
    return self.encrypt(message.bytes())
}


//SecretKey
struct SecretKey {
    core.SignedSecretKey
}

fn (self &SecretKey) sign_message(message string) ?Signature {
    return Signature { self.create_signature(message.bytes())? }
}

fn (self &SecretKey) decrypt_to_text(encrypted_message []byte) ?string {
    return self.decrypt(encrypted_message)?.bytestr()
}

fn (self &SecretKey) get_signed_public_key() ?PublicKey {
    return PublicKey { self.public_key()?.sign_and_free(self.SignedSecretKey)? }
}

//Signature
struct Signature {
    core.Signature
}

fn (self &Signature) to_bytes() ?[]byte {
    return self.Signature.serialize()
}

fn (self &Signature) to_hex() ?string {
    return hex.encode(self.to_bytes()?)
}

// import functions
// import public key from ASCII armor text format
fn read_publickey(data string) ?PublicKey {
    return PublicKey { core.signed_public_key_from_armored(data) ?}
}

// import public key from ASCII armor file format
fn read_publickey_from_file(path string) ?PublicKey {
    content := os.read_file(path) ?
    return read_publickey(content)
}

// import secret key from ASCII armor text format
fn read_secretkey(data string) ?SecretKey {
    return SecretKey { core.signed_secret_key_from_armored(data) ?}
}

// import secret key from ASCII armor file format
fn read_secretkey_from_file(path string) ?SecretKey{
    content := os.read_file(path) ?
    return read_secretkey(content)
}

fn main() {
    spk := read_publickey_from_file("./mykey_pgp.asc") ?
    ssk := read_secretkey_from_file("./mykey_private_protected_pgp.asc") ?
    println("✅ keys loaded!")

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
