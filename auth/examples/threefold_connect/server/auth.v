module main

import vweb
import json
import net.http
import net.urllib
import rand
import encoding.base64
import x.json2
import libsodium


const (
	redirect_url = "https://login.threefold.me"
	callback_url = "/callback"
	login_url = "/auth/login"
)

["/auth/login"]
fn (mut app App) login()? vweb.Result {
	/*
	 	List available providers for login and redirect to the selected provider (ThreeFold Connect)
		Returns:
        	Renders the template of login page
    */
	session := map[string]string{}
	state := rand.uuid_v4().replace("-", "")
	app_id := "localhost:8080"
	
	params := {
        "state": state,
        "appid": app_id,
        "scope": json.encode({"user": true, "email": true}),
        "redirecturl": callback_url,
        "publickey": "Tz3vDdNcnTuIUJCfndHsHzopyWCjmH+ew9bI23owPwM=",
        // "publickey": create_keys(),
    }
	app.redirect("$redirect_url?${url_encode(params)}")
	return app.text('Login page')
}

["/callback"]
fn (mut app App) callback()? vweb.Result {
	data := SignedAttempt{}
	query := app.query.clone()

	if query == {} {
        app.abort(400, signedAttemptMissing)
	}

	initial_data := data.load(query)?
	if initial_data.double_name == ""{
		app.abort(400, noDoubleName)
	}

	res := request_to_get_pub_key(initial_data.double_name)?
	if res.status_code != 200{
		app.abort(400, "Error getting user pub key")
	}

	body := json2.raw_decode(res.body)?
	public_key := body.as_map()['publicKey']
	mut arr := [32]u8{}
	for elm in base64.decode(public_key.str()){
		arr << elm
	}
	// arr = base64.decode(public_key.str()).clone()
	// println(typeof(arr).name)
	vert := libsodium.VerifyKey{}
	// println(vert.verify_string(public_key.str()))
	// signed_data := initial_data.signed_attempt
	return app.text('World')
}