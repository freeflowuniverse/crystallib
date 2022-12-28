import base64

pub fn basic_auth(users map[string]string, request http.Request) ?bool {
	mut processed_users := map[string]string{}
	for u, p in users {
		encodedauth := base64.encode('${u}:${p}'.bytes())
		processed_users['Basic ${encodedauth}'] = u
	}
	headers_keys := request.header.keys()
	mut value := ''
	if headers_keys.contains('Authorization') {
		value = request.header.get_custom(headers_keys[headers_keys.index('Authorization')])?
	}
	if processed_users[value] == '' {
		return false
	}
	return true
}
