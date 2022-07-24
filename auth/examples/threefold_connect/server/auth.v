module main

import vweb
import json
import rand
import encoding.base64
import x.json2
import libsodium




const (
	redirect_url 		= "https://login.threefold.me"
	app_id 				= "localhost:8080"
	sign_len 			= 64
)



["/login"]
fn (mut app App) login()? vweb.Result {
	server_public_key 	:= "iB0HY/EVuebM/gADfouMEaUGK7ULTtT8TWqkC2jrkXw="
	state := rand.uuid_v4().replace("-", "")
	params := {
        "state": state,
        "appid": app_id,
        "scope": json.encode({"user": true, "email": true}),
        "redirecturl": "/callback",
        "publickey": server_public_key,
    }
	app.redirect("$redirect_url?${url_encode(params)}")
	return app.text('Login Page...')
}

["/callback"]
fn (mut app App) callback()? vweb.Result {
	server_public_key 	:= "iB0HY/EVuebM/gADfouMEaUGK7ULTtT8TWqkC2jrkXw="
	server_private_key 	:= "aw1t0vrRnBlBsH1WFcGBQDwRl7si9USwJm6lik1xNmA="

	server_pk_decoded_32 := [32]u8{}
	server_sk_decoded_64 := [32]u8{}

	len_server_pk := base64.decode_in_buffer(&server_public_key, &server_pk_decoded_32)
	len_server_sk := base64.decode_in_buffer(&server_private_key, &server_sk_decoded_64)

	server_pk_decoded := server_pk_decoded_32[..]
	server_sk_decoded := server_sk_decoded_64[..]


	data := SignedAttempt{}
	query := app.query.clone()

	if query == {} {
        app.abort(400, signed_attempt_missing)
	}

	initial_data := data.load(query)?
	if initial_data.double_name == ""{
		app.abort(400, no_double_name)
	}

	res := request_to_get_pub_key(initial_data.double_name)?
	if res.status_code != 200{
		app.abort(400, "Error getting user pub key")
	}

	body 			:= json2.raw_decode(res.body)?
	user_pk 		:= body.as_map()['publicKey'].str()
	buf 			:= [32]u8{}
	_ 				:= base64.decode_in_buffer(&user_pk, &buf)
	signed_data 	:= initial_data.signed_attempt
	verify_key 		:= libsodium.VerifyKey{buf}
	verifed 		:= verify_key.verify(base64.decode(signed_data))

	if verifed == false{
		app.abort(400, "Data verfication failed!.")
	}

	verified_data 	:= base64.decode(signed_data)
	data_obj 		:= json2.raw_decode(verified_data[sign_len..].bytestr())?
	data_			:= json2.raw_decode(data_obj.as_map()['data'].str())?

	res_data_struct := ResultData{
		data_obj.as_map()['doubleName'].str(), 
		data_obj.as_map()['signedState'].str(), 
		data_.as_map()['nonce'].str(), 
		data_.as_map()['ciphertext'].str()
	}

	if res_data_struct.double_name == ""{
		app.abort(400, "Decrypted data does not contain (doubleName).")
	}

	if res_data_struct.state == ""{
		app.abort(400, "Decrypted data does not contain (state).")
	}

	if res_data_struct.double_name != initial_data.double_name{
		app.abort(400, "username mismatch!")
	}

	nonce 		:= base64.decode(res_data_struct.nonce)
	ciphertext 	:= base64.decode(res_data_struct.ciphertext)
	nonce_bff := [24]u8{}
	unsafe { vmemcpy(&nonce_bff[0], nonce.data, 24) }

	user_curve_pk 	:= []u8{len: 32}
	server_curve_sk := []u8{len: 32}
	server_curve_pk := []u8{len: 32}

	res_ := libsodium.crypto_sign_ed25519_pk_to_curve25519(user_curve_pk.data, &verify_key.public_key)
	res_server_pk := libsodium.crypto_sign_ed25519_pk_to_curve25519(server_curve_pk.data, &server_pk_decoded_32[0])
	res_server_sk := libsodium.crypto_sign_ed25519_sk_to_curve25519(server_curve_sk.data, &server_sk_decoded_64[0])

	mut new_private_key := libsodium.PrivateKey{
		public_key: server_curve_pk
		secret_key: server_curve_sk
	}

	mut box := libsodium.Box{
		nonce: nonce_bff
		public_key: user_curve_pk
		key: new_private_key
	}

	println(server_pk_decoded_32[..].map(it.hex()))
	println(server_sk_decoded_64[..].map(it.hex()))

	// println(ciphertext)

	decrypted_bytes := box.decrypt(ciphertext)
	// println(box)
	// println(decrypted_bytes)

	return app.text('World')
}