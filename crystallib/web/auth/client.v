module auth

import net.http
import json
import time
import freeflowuniverse.spiderlib.auth.jwt

// session controller that be be added to vweb projects
pub struct Client {
	url string @[required]
}

struct PostParams {
	url     string
	data    string
	timeout time.Duration
}

fn (client Client) post_request(params PostParams) !http.Response {
	mut req := http.new_request(http.Method.post, params.url, params.data)
	req.read_timeout = params.timeout
	resp := req.do() or {
		return error('Failed to send request to session authentication server: ${err.code}')
	}
	if resp.status_code == 404 {
		return error('Could not find session authentication endpoint, please make sure the auth client url is configured to the url the auth server is running at.')
	}
	if resp.status_code != 200 {
		panic('Session authentication request failed, this should never happen: ${resp.status_msg}')
	}
	return resp
}

pub fn (client Client) new_auth_tokens(params RefreshTokenParams) !AuthTokens {
	resp := client.post_request(
		url: '${client.url}/new_auth_tokens'
		data: json.encode(params)
	) or { panic(err) }
	tokens := json.decode(AuthTokens, resp.body) or { panic('This should never happen ${err}') }
	return tokens
}

pub fn (c Client) new_refresh_token(params RefreshTokenParams) !string {
	resp := http.post('${c.url}/new_refresh_token', json.encode(params))!
	// todo response error check
	token := resp.body.trim('"')
	return token
}

pub fn (c Client) new_access_token(params AccessTokenParams) !string {
	resp := http.post('${c.url}/new_access_token', json.encode(params))!
	// todo response error check
	token := resp.body.trim('"')
	return token
}

pub fn (c Client) authenticate_access_token(access_token string) ! {
	url := '${c.url}/authenticate_access_token'
	resp := http.post(url, access_token) or { panic('this should never happen ${err}') }
	if resp.status_code != 200 {
		return error(resp.body)
	}
}

pub fn (c Client) get_token_subject(access_token string) !string {
	c.authenticate_access_token(access_token) or { return error(err.msg()) }
	return jwt.SignedJWT(access_token).decode_subject() or { panic(err) }
}
