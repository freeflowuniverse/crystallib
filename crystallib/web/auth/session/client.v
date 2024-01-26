module session

import net.http
import json

pub struct Client {
	url string
}

pub fn (c Client) get_session(session_id string) !Session {
	req := http.new_request(.get, '${c.url}/get_session', session_id)
	resp := req.do()!
	if resp.status_code != 200 {
		return error(resp.body)
	}
	return json.decode(Session, resp.body)!
}
