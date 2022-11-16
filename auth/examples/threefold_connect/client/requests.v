module main

import vweb
import json
import rand
import encoding.base64
import libsodium
import toml




const (
	redirect_url = "https://login.threefold.me"
	app_id = "localhost:8080"
	sign_len = 64
)



["/login"]
fn (mut clinet ClientApp) login()! vweb.Result {
	mut server_public_key := ""
	keys := parse_keys()!
	if keys.value("server") == toml.Any(toml.Null{}){
		clinet.abort(400, file_dose_not_exist)
	} else {
		server_public_key = keys.value('server.SERVER_PUBLIC_KEY').string()
	}
	server_pk_decoded_32 := [32]u8{}
	server_curve_pk := []u8{len: 32}

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
	return clinet.redirect("$redirect_url?${url_encode(params)}")
}

["/callback"]
fn (mut clinet ClientApp) callback()! vweb.Result {
	data := SignedAttempt{}
	query := clinet.query.clone()

	if query == {} {
        clinet.abort(400, signed_attempt_missing)
	}

	initial_data := data.load(query)!
	res := request_to_server_to_verify(initial_data)!
	return clinet.text("${res.body}")
}