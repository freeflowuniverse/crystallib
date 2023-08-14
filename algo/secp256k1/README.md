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

### Gentoo

```bash
emerge dev-libs/libsecp256k1
```

## Features

- [x] Generate EC keys
- [ ] Load existing EC keys
- [x] Serialize keys
- [x] Derivate shared key
- [x] Sign using ECDSA
- [x] Verify ECDSA signature
- [x] Sign using Schnorr
- [x] Verify a Schnorr signature
- [ ] Support multi-signature with Schnorr


> TODO: describe what types of keys are, and do more checks on validity of keys as given


