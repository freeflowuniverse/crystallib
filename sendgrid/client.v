module sendgrid
import net.http
import json

pub struct Client {
pub:
	token   string
	source  string
	api_url string
}

pub struct Content {
	type_ string [json: 'type'] = 'text/html' 
	value string
}



[params]
pub struct Credintials {
pub:
	source string
	token  string
	api    string
}

pub fn new_sendgrid_client(cred Credintials) !Client {
	return Client{
		token: cred.token
		api_url: cred.api
		source: cred.source
	}
}

fn (c Client) get_headers() !http.Header {
	mut headers_map := map[string]string{}
	headers_map['Authorization'] = 'Bearer ${c.token}'
	headers_map['Content-Type'] = 'application/json'
	headers := http.new_custom_header_from_map(headers_map)!

	return headers
}

pub fn (mut c Client) new_email(sendTo []Personalizations, subject string, content []Content) !Email {
	return Email{
		personalizations: sendTo
		from: Recipiant{
			email: c.source
		}
		subject: subject
		content: content
	}
}

pub fn (mut c Client) send(email Email) !http.Response {
	mut request := http.new_request(http.Method.post, c.api_url, json.encode(email))
	request.header = c.get_headers()!

	res := request.do()!
	return res
}
