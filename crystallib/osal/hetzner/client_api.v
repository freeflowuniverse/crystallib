module hetzner

import net.http

pub struct HetznerClient {
pub mut:
	instance string
	user string
	pass string
	base string
	auth string
}


//TODO: it would have been better to use the crystallib httpclient

fn (h HetznerClient) request_get(endpoint string) !string {
	mut r := http.Request{
		url: h.base + endpoint
	}

	r.add_header(http.CommonHeader.authorization, "Basic " + h.auth)
	response := r.do()!

	if response.status_code != 200 {
		return error("could not process request ${endpoint}: error ${response.status_code} \n${response.body}")
	}

	return response.body
}

fn (h HetznerClient) request_post(endpoint string, data string) !http.Response {

	println("request post: $endpoint\n$data")

	mut r := http.Request{
		method: .post,
		data: data,
		url: h.base + endpoint
	}

	r.add_header(http.CommonHeader.authorization, "Basic " + h.auth)
	r.add_header(http.CommonHeader.content_type, "application/x-www-form-urlencoded")
	response := r.do()!

	return response
}


