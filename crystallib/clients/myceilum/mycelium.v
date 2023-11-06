module myceilum

import net.http
import json

const server_url = 'http://localhost:8989/api/v1/messages'

pub struct Destination {
	pk string
}

pub struct MsgRequest {
pub:
	dst     Destination
	payload string
}

pub struct Msg {
	id      string
	src_ip  string [json: 'srcIP']
	src_pk  string [json: 'srcPk']
	dst_ip  string [json: 'dstIp']
	dst_pk  string [json: 'dstPk']
	payload string
}

pub fn send_msg(pk string, payload string, wait bool) !http.Response {
	mut url := myceilum.server_url
	if wait {
		url = '${url}\\?reply_timeout\\=120'
		println(url)
	}
	msg_req := MsgRequest{
		dst: Destination{
			pk: pk
		}
		payload: payload
	}

	return http.post_json(url, json.encode(msg_req))!
}

pub fn receive_msg(wait bool) !Msg {
	mut url := myceilum.server_url
	if wait {
		url = '${url}\\?timeout\\=60'
	}
	res := http.get(url)!
	msg := json.decode(Msg, res.body)!
	return msg
}

pub fn get_msg_status(id string) ! {
	mut url := '${myceilum.server_url}/status/${id}'
	res := http.get(url)!
	println(res.body)
}

pub fn reply_msg(id string, pk string, payload string) !http.Response {
	mut url := '${myceilum.server_url}/reply/${id}'
	msg_req := MsgRequest{
		dst: Destination{
			pk: pk
		}
		payload: payload
	}

	return http.post_json(url, json.encode(msg_req))!
}
