module main

import vweb
import json
import rand
import encoding.base64
import libsodium




const (
	redirect_url = "https://login.threefold.me"
	app_id = "localhost:8080"
	sign_len = 64
)



["/login"]
fn (mut clinet ClientApp) login()? vweb.Result {
	server_public_key 	:= "iB0HY/EVuebM/gADfouMEaUGK7ULTtT8TWqkC2jrkXw="
	server_pk_decoded_32 := [32]u8{}
	server_curve_pk := []u8{len: 32}

	// create_keys() 
	// TODO: will handle this function to create a new keys and save them into file.
	// then if the file contains the key, will take it from file, otherways will genrate new one.

	_ := base64.decode_in_buffer(&server_public_key, &server_pk_decoded_32)
	_ := libsodium.crypto_sign_ed25519_pk_to_curve25519(server_curve_pk.data, &server_pk_decoded_32[0])

	state := rand.uuid_v4().replace("-", "")
	params := {
        "state": state,
        "appid": app_id,
        "scope": json.encode({"user": true, "email": true}),
        "redirecturl": "/callback",
        "publickey": base64.encode(server_curve_pk[..]),
    }
	clinet.redirect("$redirect_url?${url_encode(params)}")
	return clinet.text('Login Page...')
}

["/callback"]
fn (mut clinet ClientApp) callback()? vweb.Result {
	data := SignedAttempt{}
	query := clinet.query.clone()

	if query == {} {
        clinet.abort(400, signed_attempt_missing)
	}

	initial_data := data.load(query)?
	res := request_to_server_to_verify(initial_data)?
	return clinet.text("${res.body}")
}