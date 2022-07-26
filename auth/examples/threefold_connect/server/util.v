module main
import net.http
import json


struct CustomResponse {
	status  int
	message string
}

struct SignedAttempt {
    signed_attempt string
    double_name    string
}

struct ResultData {
    double_name    	string
    state    		string
	nonce	    	string
	ciphertext    	string
}

const (
	kyes_file_path 			= '../keys.toml'
    signed_attempt_missing  = 'signedAttempt parameter is missing.'
    invalid_json   			= 'Invalid JSON Payload.'
    no_double_name   		= 'DoubleName is missing.'
	data_verfication_field 	= 'Data verfication failed!.'
	not_contain_doublename 	= 'Decrypted data does not contain (doubleName).'
	not_contain_state 		= 'Decrypted data does not contain (state).'
	username_mismatch 		= 'username mismatch!'
	data_decrypting_error 	= 'Error decrypting data!'
	email_not_verified 		= 'Email is not verified'
)

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

pub fn request_to_verify_sei(sei string)? http.Response{
	header := http.new_header_from_map({
		http.CommonHeader.content_type: 'application/json',
	})

	request := http.Request{
		url: "https://openkyc.live/verification/verify-sei"
		method: http.Method.post
		header: header,
		data: json.encode({"signedEmailIdentifier": sei}),
	}
	result := request.do() ?
	return result
}

fn (c CustomResponse) to_json() string {
    return json.encode(c)
}