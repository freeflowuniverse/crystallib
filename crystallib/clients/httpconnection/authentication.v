module httpconnection

import encoding.base64

pub fn (mut conn HTTPConnection) basic_auth(username string, password string) {
	credentials := base64.encode_str('${username}:${password}')
	conn.default_header.add(.authorization, 'Basic ${credentials}')
}
