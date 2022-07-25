module main

// import libsodium
// import encoding.base64
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

fn (s SignedAttempt) load (data map[string]string)? SignedAttempt {
    data_ 			:= json2.raw_decode(data['signedAttempt'])?
	signed_attempt 	:= data_.as_map()["signedAttempt"]?.str()
	double_name 	:= data_.as_map()["doubleName"]?.str()
	initial_data 	:= SignedAttempt{signed_attempt, double_name}
	return initial_data
}

const (
    signed_attempt_missing  = 'signedAttempt parameter is missing.'
	server_host				= "http://localhost:8000"
)

// pub fn create_keys() {
// 	generate_signing_key()
// 	encoded_secret := base64.encode(signing_key.bytes())
// 	// encoded_public := base64.encode("$signing_key.verify_key.public_key")
// 	println(encoded_secret)
// 	// println(encoded_public)
// 	// return encoded
// }

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

pub fn request_to_server_to_verify(data SignedAttempt)? http.Response{
	header := http.new_header_from_map({
		http.CommonHeader.content_type: 'application/json',
	})

	request := http.Request{
		url: "${server_host}/verify"
		method: http.Method.post
		header: header,
		data: json.encode(data),
	}
	result := request.do() ?
	return result
}
