module milvus

import net.http
import json

pub struct Client {
	endpoint string = 'http://localhost:19530'
	token    string
}

pub fn new(endpoint string, token string) Client {
	return Client{
		endpoint: endpoint
		token: token
	}
}

fn (c Client) add_headers(mut r http.Request) ! {
	r.add_custom_header('Authorization', 'Bearer ${c.token}')!
	r.add_custom_header('Content-Type', 'application/json')!
}

struct MilvusResponse {
	code    u32
	data    string [raw]
	message string
}

fn (c Client) do_request(mut req http.Request) !string {
	c.add_headers(mut req)!
	res := req.do()!
	milvus_response := json.decode(MilvusResponse, res.body) or {
		return error('failed to decode milvus response: ${err}')
	}
	if res.status() != http.Status.ok {
		return error('milvus error code ${milvus_response.code}: ${milvus_response.message}')
	}

	return milvus_response.data
}
