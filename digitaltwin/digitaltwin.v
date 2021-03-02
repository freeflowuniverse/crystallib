module digitaltwin

import libsodium
// import despiegk.crystallib.redisclient
import os

// pub fn factory(redis redisclient.Redis) ?DigitalTwinFactory { // FIXME
pub fn factory(redis int) ?DigitalTwinFactory {
	seedlen := 32 // FIXME (extracted from sodium lib)

	mut pk := libsodium.PrivateKey{
		public_key: []byte{len: libsodium.public_key_size}
		secret_key: []byte{len: libsodium.secret_key_size}
	}

	mut path := os.home_dir() + '/.digitaltwin'
	if !os.exists(path) {
		os.mkdir_all(path)?
	}

	// seed will contains data needed to build
	// private key, it will be generated or loaded
	// from local file if existing
	mut seed := []byte{len: seedlen}

	path_seed := os.join_path(path, 'seed')
	if !os.exists(path_seed) {
		// generating new seed and saving it
		libsodium.randombytes_buf(seed.data, size_t(seedlen))

		println("[+] key: saving new generated seed: $path_seed")
		os.write_file_array(path_seed, seed)?

	} else {
		// loading existing seed from file
		seed = os.read_bytes(path_seed)?

		println("[+] key: seed loaded from local file")
	}

	println(seed)

	// building private key from seed
	libsodium.crypto_box_seed_keypair(pk.public_key.data, pk.secret_key.data, seed.data)
	println(pk)

	mut me := DigitalTwinME{}

	return DigitalTwinFactory{
		me: me
		redis: &redis
		privkey: pk
	}
}
