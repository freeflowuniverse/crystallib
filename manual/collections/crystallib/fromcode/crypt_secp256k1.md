# libsecp256k1

This is a lib256k1 binding for vlang.

## Requirements

make sure the lib is installed

### macOS

```bash
brew install secp256k1
```

### Ubuntu

Compile latest release, version included in Ubuntu is outdated.

```
apt-get install -y build-essential wget autoconf libtool

wget https://github.com/bitcoin-core/secp256k1/archive/refs/tags/v0.3.2.tar.gz
tar -xvf v0.3.2.tar.gz

cd secp256k1-0.3.2/
./autogen.sh
./configure
make -j 5
make install
```

### Arch

```bash
pacman -Su extra/libsecp256k1
```

### Gentoo

```bash
emerge dev-libs/libsecp256k1
```

## Features

- [x] Generate EC keys
- [x] Load existing EC keys
- [x] Serialize keys
- [x] Derivate shared key
- [x] Sign using ECDSA
- [x] Verify ECDSA signature
- [x] Sign using Schnorr
- [x] Verify a Schnorr signature
- [ ] Support multi-signature with Schnorr

## How to use

There are 4 differents things / features to understand in this secp256k1 implementation (wrapper).

### Public and Privaye keys for secp256k1

This is a simple private/public key schema. This wrapper deals with hexdump of keys.

- Private key is `32 bytes` long (eg: `0x4a21f247ff3744e211e95ec478d5aba94a1d6d8bed613e8a9faece6d048399fc`)
- Public key is `33 bytes` long (eg: `0x02df72fc4fa607ca3478446750bf9f8510242c4fa5849e77373d71104cd0c82ea0`)

In this library, you can instanciate a secp256k1 object from 3 ways:
```vlang
import freeflowuniverse.crystallib.crypt.secp256k1
secp256k1.new()
```
Constructor without any arguments, will generate a new private and public key

```vlang
secp256k1.new(privkey: '0x4a21f247ff3744e211e95ec478d5aba94a1d6d8bed613e8a9faece6d048399fc')
```
Using `privkey` argument, this will create an object from private key and generate corresponding public key

```vlang
secp256k1.new(pubkey: '0x02df72fc4fa607ca3478446750bf9f8510242c4fa5849e77373d71104cd0c82ea0')
```
Using `privkey` argument, this will create an object with only the public key,
which can be used for shared key or signature verification

### Shared Keys

Library `secp256k1` have one feature which allows you to derivate a `shared intermediate common key` from
the private key of one party and the public key from the other party.

Example:
- Shared key from `Bob Private Key` + `Alice Public Key` = `Shared Key`
- Shared key from `Alice Private Key` + `Bob Public Key` = `Shared Key` (the same)

Using this feature, with your private key and target public key, you can derivate a `shared (secret) key`
that only you both knows. This is really interresting to switch to a symetric encryption using that key
as encryption key or use any well known secret without exchanging it.

To use the shared key feature, just call the `sharedkeys()` method:
```vlang
bob := secp256k1.new(privhex: '0x478b45390befc3097e3e6e1a74d78a34a113f4b9ab17deb87e9b48f43893af83')!
alicepub := secp256k1.new(pubkey: '0x034a87ad6fbf83d89a91c257d4cc038828c6ed9104738ffd4bb7e5069858d4767b')!

shared := bob.sharedkeys(alicepub)
// shared = 0xf114df29d930f0cd37f62cbca36c46773a42bf87e12edcb35d47c4bfbd20514d
```

This works the same in the opposite direction:
```vlang
alice := secp256k1.new(privhex: '0x8225825815f42e1c24a2e98714d99fee1a20b5ac864fbcb7a103cd0f37f0ffec')!
bobpub := secp256k1.new(pubkey: '0x03310ec949bd4f7fc24f823add1394c78e1e9d70949ccacf094c027faa20d99e21')!

shared := alice.sharedkeys(bobpub)
// shared = 0xf114df29d930f0cd37f62cbca36c46773a42bf87e12edcb35d47c4bfbd20514d (same shared key)
```

### ECDSA Signature

This is the default signature method. When doing a signature, you don't sign the actual data but you
have to sign a hash (sha256) of the data. This payload needs to be fixed length. The return signature
is a `64 bytes` long response.

When doing a signature using ecdsa method, you sign using the private key and verify using the public key
of the same party. If **Bob** sign something, you have to verify using **Bob** public key is the signature matches.

If signature matches, that mean that is really **Bob** who signed the hash.
Here, you need the signature and the message separately.

```vlang
sstr := alice.sign_str("Hello World !")
valid := alicepub.verify_str(sstr, "Hello World !")
// valid = true
```

### Schnorr Signature

This is the new prefered signature method. In theory, this method can in addition be able to sign
using multiple parties without storing signature of everyone, signature can be chained but this is not
implemented in this wrapper (lack of source documentation and understanding).

In practice, code wide, wrapper take care to handle everything for you and this really looks like
the same way than ecdsa.

```vlang
schnorr_sstr := alice.schnorr_sign_str("Hello World !")
valid := alicepub.schnorr_verify_str(schnorr_sstr, "Hello World !")
// valid = true
```
