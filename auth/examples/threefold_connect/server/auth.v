module main

import vweb
import json
import rand
import encoding.base64
import x.json2
import libsodium




const (
	redirect_url = "https://login.threefold.me"
	callback_url = "/callback"
	sign_len = 64
	server_public_key = "EI/xFXcF5GjkRQOLxBNjY8eC0eO9ylM+sNcPNEJkAAY="
	server_private_key = "VwgmwdoJQ4+L65nWy35nuzi8dsfnJ89C+ejxT1M2pnI="
)




["/login"]
fn (mut app App) login()? vweb.Result {
	/*
	 	List available providers for login and redirect to the selected provider (ThreeFold Connect)
		Returns:
        	Renders the template of login page
    */
	state := rand.uuid_v4().replace("-", "")
	app_id := "localhost:8080"
	
	params := {
        "state": state,
        "appid": app_id,
        "scope": json.encode({"user": true, "email": true}),
        "redirecturl": callback_url,
        "publickey": server_public_key,
    }
	app.redirect("$redirect_url?${url_encode(params)}")
	return app.text("")
}

["/callback"]
fn (mut app App) callback()? vweb.Result {
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
	public_key_ 	:= body.as_map()['publicKey']
	buf 			:= [32]u8{}
	_ 				:= base64.decode_in_buffer_bytes(public_key_.str().bytes(), &buf)
	signed_data 	:= initial_data.signed_attempt
	verify_key 		:= libsodium.VerifyKey{buf}
	verifed 		:= verify_key.verify(base64.decode(signed_data))

	if verifed == false{
		app.abort(400, "Data verfication failed!.")
	}

	verified_data 	:= base64.decode(signed_data)
	data_obj 		:= json2.raw_decode(verified_data[sign_len..].bytestr())?
	data_			:= json2.raw_decode(data_obj.as_map()['data'].str())?

	double_name 	:= data_obj.as_map()['doubleName'].str()
	state 			:= data_obj.as_map()['signedState'].str()
	nonce 			:= data_.as_map()['nonce'].str()
	ciphertext 		:= data_.as_map()['ciphertext'].str()

	end_data 		:= ResultData{double_name, state, nonce, ciphertext}
	ciptxt_decoded 	:= base64.decode(end_data.ciphertext)

	nonce_decoded 	:= base64.decode(end_data.nonce)

	nonce_bff := [24]u8{}
	unsafe { vmemcpy(&nonce_bff[0], nonce_decoded.data, 24) }

	if end_data.double_name == ""{
		app.abort(400, "Decrypted data does not contain (doubleName).")
	}

	if end_data.state == ""{
		app.abort(400, "Decrypted data does not contain (state).")
	}

	if end_data.double_name != initial_data.double_name{
		app.abort(400, "username mismatch!")
	}

	public_key := base64.decode(server_public_key)
	secret_key := base64.decode(server_private_key)

	mut new_private_key := libsodium.PrivateKey{
		public_key: public_key
		secret_key: secret_key
	}

	v_public_key := verify_key.public_key
	mut new_v_public_key := []u8{}
	new_v_public_key = v_public_key[..].clone()
	box := libsodium.new_box(new_private_key, new_v_public_key)

	println(box.decrypt(ciptxt_decoded, nonce_bff))
	return app.text('World')
}