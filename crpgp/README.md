# CRPGP

This module based on [threefold/crpgp](https://github.com/threefoldtech/crpgp) repo, which is a wrapper for [rpgp](https://github.com/rpgp/rpgp)

## Install

All needed libs can be installed from [install.sh](./install.sh)

## High Level API

- List of supported functions with a description for each method

| Function                              | Description                                                                      | Input             | Output          |
| ------------------------------------- | -------------------------------------------------------------------------------- | ----------------- | --------------- |
| generate_key                          | generate a signed secret key using name, email, comment, key_type and key_length | KeyParams         | SignedSecretKey |
| SignedSecretKey.get_signed_public_key | get a signed public key from signed secret key                                   |                   | SignedPublicKey |
| import_publickey                      | import signed public key in armored format                                       | string            | SignedPublicKey |
| import_publickey_from_file            | like import_publickey but from a file                                            | string            | SignedPublicKey |
| import_secretkey                      | import signed secret key in armored format                                       | string            | SignedSecretKey |
| import_secretkey_from_file            | like import_secretkey but from a file                                            | string            | SignedSecretKey |
| SignedPublicKey.sign_message          | sign message with your signed public key                                         | string            | Signature       |
| SignedSecretKey.verify_signature      | verify signature for message with your signed secret key                         | Signature, string | bool            |
| SignedPublicKey.encrypt_from_text     | encrypt message from text using your signed public key                           | string            | []byte          |
| SignedSecretKey.decrypt_to_text       | decrypt encrypted messages to text using your signed secret key                  | []byte            | string          |
| Signature.to_bytes                    | convert signature to bytes                                                       |                   | []byte          |
| Signature.to_hex                      | convert signature to hex                                                         |                   | string          |
| signature_from_hex                    | convert hex string to signature                                                  | string            | Signature       |

### Notes:
- key_type is enum of [`cv25519`, `rsa`], by default key_type will be `cv25519`
- key_length used if key_type is `rsa` and `3072` is a default value

## How to use ?

- We will go together step by step to illustrate how to use this module.

- Import crpgp module

```v
import crpgp
```

- We have **two** options here, generate a new key, or import

1. Generate:
- CV25519 key:

```v
ssk := crpgp.generate_key(name: <YOUR_NAME>, email: <YOUR_EMAIL>) ?
```

- RSA key

```v
// key_length 3072 if not passed
ssk := crpgp.generate_key(name: <YOUR_NAME>, email: <YOUR_EMAIL>, key_type: .rsa) ?
```
or
```v
ssk := crpgp.generate_key(name: <YOUR_NAME>, email: <YOUR_EMAIL>, key_type: .rsa, key_length: <LENGTH>) ?
```

2. Import signed secret key from file

```v
ssk := crpgp.import_secretkey_from_file(<FILE_PATH>) ?
```

- Now we have a signed secret key, let us get a signed public key, also we have **two** options, get from secret key or import

1. Get signed public key from signed secret key

```v
spk := ssk.get_signed_public_key() ?
```

2. import signed public key from file

```v
spk := crpgp.import_publickey_from_file(<FILE_PATH>) ?
```

- Now we have a signed public and secret key, let us try to sign and verify a message

```v
message := "these are my secrets\n12345"
mut sig := ssk.sign_message(message) ?
println(sig.to_hex() ?) // In case we want to convert it to hex, here just to display it

if spk.verify_signature(sig, message) {
    println('✅ message signed and verified!')
}
```

- let us try encrypt and decrypt message.

```v
encrypted := spk.encrypt_from_text(message) ?
decrypted := ssk.decrypt_to_text(encrypted) ?
if message == decrypted {
    println('✅ message encrypted and decrypted!')
}
```

- Done !
