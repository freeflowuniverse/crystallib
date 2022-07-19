module main

import libsodium
import encoding.base64
import json
import x.json2
import net.http



struct CustomResponse {
	status  int
	message string
}

struct SignedAttempt {
    signed_attempt string
    double_name    string
}

fn (c CustomResponse) to_json() string {
    return json.encode(c)
}

fn (s SignedAttempt) load(data map[string]string)? SignedAttempt {
    data_ 			:= json2.raw_decode(data['signedAttempt'])?
	signed_attempt 	:= data_.as_map()["signedAttempt"].str()
	double_name 	:= data_.as_map()["doubleName"].str()
	initial_data 	:= SignedAttempt{signed_attempt, double_name}
	return initial_data
}

const (
    invalid_json   			= 'Invalid JSON Payload.'
    signedAttemptMissing   	= 'signedAttempt parameter is missing.'
    noDoubleName   			= 'DoubleName is missing.'
)

pub fn create_keys() string {
	signing_key := libsodium.generate_signing_key()
	encoded := base64.encode("$signing_key".bytes())
	return encoded
}

pub fn url_encode(map_ map[string]string) string {
	mut formated := ""

	for k, v in map_ {
		if formated != "" {
			formated += "&" + k + "=" + v
		} else {
			formated = k + "=" + v
		}
	}
	return formated
}

pub fn request_to_get_pub_key(username string)? http.Response{
	mut header := http.new_header_from_map({
		http.CommonHeader.content_type: 'application/json'
	})
	config := http.FetchConfig{
		header: header,
		method: http.Method.get

	}
	url := "https://login.threefold.me/api/users/$username"
	resp := http.fetch(http.FetchConfig{ ...config, url: url })?
	return resp
}

pub fn (mut app App)abort(status int, message string){
	app.set_status(status, message)
	er := CustomResponse{status, message}
	app.json(er.to_json())
}