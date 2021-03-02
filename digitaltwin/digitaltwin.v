module digitaltwin

import libsodium
import despiegk.crystallib.redisclient
import os

pub fn factory(redis redisclient.Redis) ?DigitalTwinFactory {
	mut path := os.home_dir() + '/.digitaltwin'
	if !os.exists(path) {
		os.mkdir_all(path) ?
	}
	path_key := os.join_path(path, 'key.priv')
	if !os.exists(path_key) {
		pkey := libsodium.new_private_key()
		// mut f := os.open(path_key) ?
		os.write_file_array(path_key, pkey.secret_key) ?
		path_key2 := os.join_path(path, 'key.pub')
		os.write_file_array(path_key2, pkey.public_key) ?
	} else {
		// read the key
		secret_key := os.read_bytes(path_key) ?
		// NOW need to get the private key obj back TODO:
		mut privkey := libsodium.PrivateKey{}
		privkey.secret_key = secret_key
		privkey.public_key = secret_key //PUB KEY CHANGE
		println(secret_key)
		panic('s')
		privkey := '' // TODO: need to be obj? dont know how
	}

	mut me := DigitalTwinME{}

	return DigitalTwinFactory{
		me: me
		redis: &redis
		privkey: privkey
	}
}
