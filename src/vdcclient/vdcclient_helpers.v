module vdcclient

import net.http

// These functions used as helper methods to get, post, delete http request
// with Authorization headers for the VDC client

pub fn get(url string, auth_cred string) http.Response {
	mut config := http.FetchConfig{}
	config.header = http.new_header({ key: .authorization, value: 'Basic $auth_cred' },
		
		key: .content_type
		value: 'application/json'
	)
	config.method = http.Method.get
	return http.fetch(url, config) or { panic("Can't GET with error $err") }
}

pub fn get_with_body_param(url string, auth_cred string, body string) http.Response {
	mut config := http.FetchConfig{}
	config.data = body
	config.header = http.new_header({ key: .authorization, value: 'Basic $auth_cred' },
		
		key: .content_type
		value: 'application/json'
	)
	config.method = http.Method.get
	return http.fetch(url, config) or { panic("Can't GET with error $err") }
}

pub fn post(url string, auth_cred string, body string) http.Response {
	mut config := http.FetchConfig{}
	config.data = body
	config.header = http.new_header({ key: .authorization, value: 'Basic $auth_cred' },
		
		key: .content_type
		value: 'application/json'
	)
	config.method = http.Method.post
	return http.fetch(url, config) or { panic("Can't POST with error $err") }
}

pub fn delete(url string, auth_cred string, body string) http.Response {
	mut config := http.FetchConfig{}
	config.data = body
	config.header = http.new_header({ key: .authorization, value: 'Basic $auth_cred' },
		
		key: .content_type
		value: 'application/json'
	)
	config.method = http.Method.delete
	return http.fetch(url, config) or { panic("Can't DELETE with error $err") }
}

