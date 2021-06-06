module vdcclient

import net.http
import json
import x.json2

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

pub fn parse_alerts(response string) []Alert {
	decoded := json2.raw_decode(response) or { panic("Can't decode your response with error $err") }
	raw := decoded.arr()
	mut alerts := json.decode([]Alert, response) or {
		panic("Can't decode your response with error $err")
	}

	for i, mut alert in alerts {
		alert.alert_type = raw[i].as_map()['type'].str()
	}

	return alerts
}

pub fn parse_backups(response string) []Backup {
	decoded := json2.raw_decode(response) or { panic("Can't decode your response with error $err") }
	raw := decoded.arr()
	mut backups := json.decode([]Backup, response) or {
		panic("Can't decode your response with error $err")
	}

	for i, mut backup in backups {
		backup.progress.total_items = raw[i].as_map()['progress'].as_map()['totalItems'].int()
		backup.progress.item_backedup = raw[i].as_map()['progress'].as_map()['itemsBackedUp'].int()
	}

	return backups
}
