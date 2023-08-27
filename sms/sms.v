module sms

import os
import x.json2
import log

const success_status = "queued"

pub struct Client {
pub:
	api_url string = "https://api.twilio.com/2010-04-01/Accounts"
	token string
	sid string
	source string
pub mut:
	logger log.Log
}

[params]
pub struct Credentials {
pub:
	sid string
	token string
	source string
}

[params]
pub struct Message {
pub:
	content string
	destination string
}

pub struct Result {
pub:
	level string
	content string
	more_info string
}

pub fn new(cred Credentials, mut logger log.Log) !Client {
	return Client{
		sid: cred.sid
		token: cred.token
		source: cred.source
		logger: logger
	}
}

fn (mut c Client) validate_credentials() ! {
	if c.sid != "" && c.token != "" && c.source != "" {
		return 
	}

	return error("missing credentials")
}

fn get_value(res json2.Any, key string) string {
	mp := res.as_map()
	ret := mp[key] or {
		println("couldn't parse the key: ${key}")
		return ""
	}

	return ret.str()
}


pub fn (mut c Client) send(msg Message) !Result {
	c.validate_credentials() or {
		return error(err.str())
	}

	cmd := "curl \
	-X POST ${c.api_url}/${c.sid}/Messages.json	\
	-d 'Body=${msg.content}' \
	-d 'From=${c.source}' \
	-d 'To=${msg.destination}' \
	-u '${c.sid}:${c.token}' \
	-s"

	res := os.execute(cmd)

	res_obj := json2.raw_decode(res.output) or {
		c.logger.error(err.str())
		return Result{}
	}

	if get_value(res_obj, "status") != "queued" {
		return Result{
			level: "error"
			content: get_value(res_obj, "message")
			more_info: get_value(res_obj, "more_info")
		}
	}

	return Result{
		level: "success"
		content: get_value(res_obj, "body")
	}
}