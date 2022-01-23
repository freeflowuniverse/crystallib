module taiga

import x.json2
import json
import net.http
import despiegk.crystallib.redisclient
import despiegk.crystallib.crystaljson
import crypto.md5

struct TaigaConnectionSettings {
	comments_story bool = true
	comments_issue bool = true
	comments_task  bool = true
}

[heap]
struct TaigaConnection {
mut:
	redis         redisclient.Redis
	url           string
	auth          AuthDetail
	cache_timeout int
	settings      TaigaConnectionSettings
pub mut:
	projects map[int]&Project
	users    map[int]&User
	stories  map[int]&Story
	tasks    map[int]&Task
	epics    map[int]&Epic
	comments map[int]&Comment
	issues   map[int]&Issue
}

// needed to get singleton
fn init2() TaigaConnection {
	mut conn := TaigaConnection{
		redis: redisclient.connect('127.0.0.1:6379') or { redisclient.Redis{} }
	}
	return conn
}

// singleton creation
const connection = init2()

// make sure to use new first, so that the connection has been initted
// then you can get it everywhere
pub fn connection_get() &TaigaConnection {
	return &taiga.connection
}

// const conn = init_connection()

struct AuthDetail {
mut:
	auth_token        string
	bio               string
	email             string
	full_name         string
	full_name_display string
	gravatar_id       string
	id                int
	is_active         bool
	username          string
	uuid              string
}

pub fn new(url string, login string, passwd string, cache_timeout int) &TaigaConnection {
	/*
	Create a new taiga client
	Inputs:
		url: Taiga url
		login: Username that used in login
		passwd: Username password
		cache_timeout: Expire time in seconds for caching
		full: flag to detect if we need to get the full data or not

	Output:
		TaigaConnection: Client contains taiga auth details, taiga url, redis cleint and cache timeout.
	*/
	mut conn := connection_get()
	println('- Connection Succeeded!')

	conn.auth(url, login, passwd) or {
		panic("Could not connect to $url with $login and passwd:'$passwd'\n$err")
	}
	conn.cache_timeout = cache_timeout
	load_data() or { panic("Can't load data, for details: $err") } // Must panic if load data not working
	return conn
}

fn (mut h TaigaConnection) header() http.Header {
	/*
	Create a new header for Content type and Authorization

	Output:
		header: http.Header with the needed headers
	*/
	mut header := http.new_header_from_map({
		http.CommonHeader.content_type:  'application/json'
		http.CommonHeader.authorization: 'Bearer $h.auth.auth_token'
	})
	return header
}

// calculate the key for the cache starting from data and prefix
fn cache_key(prefix string, postdata string) string {
	/*
	Create Cache Key
	Inputs:
		prefix: Taiga elements types, ex (projects, issues, tasks, ...).

	Output:
		cache_key: key that will be used in redis
	*/
	mut data2 := postdata
	if data2.len > 16 {
		data2 = md5.hexhash(data2)
	}
	if data2.len > 0 {
		return 'taiga:' + prefix + ':' + data2
	}
	return 'taiga:' + prefix
}

fn (mut h TaigaConnection) cache_get(prefix string, postdata string, cache bool) string {
	/*
	Get from Cache
	Inputs:
		prefix: Taiga elements types, ex (projects, issues, tasks, ...).
		reqdata: data used in the request.
		cache: Flag to enable caching.
	Output:
		result: If cache ture and no thing stored or cache false will return empty string
	*/
	mut text := ''
	if cache {
		text = h.redis.get(cache_key(prefix, postdata)) or { '' }
	}
	return text
}

fn (mut h TaigaConnection) cache_set(prefix string, postdata string, data string, cache bool) ? {
	/*
	Set Cache
	Inputs:
		prefix: Taiga elements types, ex (projects, issues, tasks, ...).
		reqdata: data used in the request.
		data: Json encoded data.
		cache: Flag to enable caching.
	*/
	if cache {
		key := cache_key(prefix, postdata)
		h.redis.set(key, data) ?
		h.redis.expire(key, h.cache_timeout) or {
			panic('should never get here, if redis worked expire should also work.$err')
		}
	}
}

pub fn (mut h TaigaConnection) cache_drop_all() ? {
	/*
	Drop all cache related to taiga
	*/
	all_keys := h.redis.keys('taiga:*') ?
	for key in all_keys {
		h.redis.del(key) ?
	}
}

pub fn (mut h TaigaConnection) cache_drop(prefix string) ? {
	/*
	Drop specific key cache related to taiga
	*/
	all_keys := h.redis.keys('taiga:$prefix*') ?
	for key in all_keys {
		h.redis.del(key) ?
	}
}

// fn (mut h TaigaConnection) post_json_dict_any(_amyprefix string, postdata string, cache bool) ?map[string]json2.Any {
// 	/*
// 	Post Request with Json Data
// 	Inputs:
// 		prefix: Taiga elements types, ex (projects, issues, tasks, ...).
// 		postdata: Json encoded data.
// 		cache: Flag to enable caching.
// 		authenticated: Flag to add authorization flag with the request.

// 	Output:
// 		response: response as dict of json2 any
// 	*/
// 	mut result := h.post_json_str(prefix, postdata, cache) ?
// 	data_raw := json2.raw_decode(result) ?
// 	data := data_raw.as_map()
// 	return crystaljson.json_dict(data,false)
// }

fn (mut h TaigaConnection) post_json_dict(prefix string, postdata string, cache bool) ?map[string]json2.Any {
	/*
	Post Request with Json Data
	Inputs:
		prefix: Taiga elements types, ex (projects, issues, tasks, ...).
		postdata: Json encoded data.
		cache: Flag to enable caching.
		authenticated: Flag to add authorization flag with the request.

	Output:
		response: response as dict of further json strings
	*/
	mut result := h.post_json_str(prefix, postdata, cache) ?
	return crystaljson.json_dict_any(result, false, [], [])
}

fn (mut h TaigaConnection) post_json_list(prefix string, postdata string, cache bool) ?[]string {
	/*
	Post Request with Json Data
	Inputs:
		prefix: Taiga elements types, ex (projects, issues, tasks, ...).
		postdata: Json encoded data.
		cache: Flag to enable caching.
		authenticated: Flag to add authorization flag with the request.

	Output:
		response: response as list of json strings
	*/
	mut result := h.post_json_str(prefix, postdata, cache) ?
	return crystaljson.json_list(result, false)
}

// this is the method which calls to the service
fn (mut h TaigaConnection) post_json_str(prefix string, postdata string, cache bool) ?string {
	/*
	Post Request with Json Data
	Inputs:
		prefix: Taiga elements types, ex (projects, issues, tasks, ...).
		postdata: Json encoded data.
		cache: Flag to enable caching.
		authenticated: Flag to add authorization flag with the request.

	Output:
		response: response as string.
	*/
	// Post with auth header
	mut result := ''
	cached_data := h.cache_get(prefix, postdata, cache)
	if cached_data.len > 0 {
		return cached_data
	}
	url := '$h.url/api/v1/$prefix'
	mut req := http.new_request(http.Method.post, url, postdata) ?
	// println(" --- $prefix\n$postdata")
	if prefix.contains('auth') {
		response := http.post_json('$h.url/api/v1/$prefix', postdata) ?
		result = response.text
	} else {
		req.header = h.header()
		req.add_custom_header('x-disable-pagination', 'True') ?
		response := req.do() ?
		if response.status_code == 201 {
			result = response.text
		} else {
			return error('could not post: $url\n$response')
		}
		result = response.text
	}
	h.cache_set(prefix, postdata, result, cache) ?
	return result
}

fn (mut h TaigaConnection) get_json_dict_any(prefix string, data string, cache bool) ?map[string]json2.Any {
	/*
	Get Request with Json Data
	Inputs:
		prefix: Taiga elements types, ex (projects, issues, tasks, ...).
		data: Json encoded data.
		cache: Flag to enable caching.

	Output:
		response: response as Json2.Any map.
	*/
	mut result := h.get_json_str(prefix, data, cache) ?
	data_raw := json2.raw_decode(result) ?
	data2 := data_raw.as_map()
	return data2
}

fn (mut h TaigaConnection) get_json_list(prefix string, getdata string, cache bool) ?[]string {
	/*
	Get Request with Json Data
	Inputs:
		prefix: Taiga elements types, ex (projects, issues, tasks, ...).
		data: Json encoded data.
		cache: Flag to enable caching.

	Output:
		response: list of strings.
	*/
	mut result := h.get_json_str(prefix, getdata, cache) ?
	return crystaljson.json_list(result, false)
}

fn (mut h TaigaConnection) get_json_str(prefix string, getdata string, cache bool) ?string {
	/*
	Get Request with Json Data
	Inputs:
		prefix: Taiga elements types, ex (projects, issues, tasks, ...).
		data: Json encoded data.
		cache: Flag to enable caching.

	Output:
		response: response as string.
	*/
	mut result := h.cache_get(prefix, getdata, cache)
	if result == '' {
		// println("MISS1")
		url := '$h.url/api/v1/$prefix'
		// println(' ... $url')
		mut req := http.new_request(http.Method.get, url, getdata) ?
		req.header = h.header()
		req.add_custom_header('x-disable-pagination', 'True') ?
		res := req.do() ?
		if res.status_code == 200 {
			result = res.text
		} else {
			return error('could not get: $url\n$res')
		}
		h.cache_set(prefix, getdata, result, cache) ?
	}
	return result
}

// fn (mut h TaigaConnection) edit_json_dict_any(prefix string, id int, data string, cache bool) ?map[string]json2.Any {
// 	/*
// 	Patch Request with Json Data
// 	Inputs:
// 		prefix: Taiga elements types, ex (projects, issues, tasks, ...).
// 		id: id of the element.
// 		data: Json encoded data.
// 		cache: Flag to enable caching.

// 	Output:
// 		response: response Json2.Any map.
// 	*/
// 	result := h.edit_json(prefix,id,data,cache)?
// 	data_raw := json2.raw_decode(result) ?
// 	data2 := data_raw.as_map()
// 	return data2
// }

fn (mut h TaigaConnection) edit_json(prefix string, id int, data string) ?string {
	/*
	Patch Request with Json Data
	Inputs:
		prefix: Taiga elements types, ex (projects, issues, tasks, ...).
		id: id of the element.
		data: Json encoded data.

	Output:
		response: response Json2.Any map.
	*/
	url := '$h.url/api/v1/$prefix/$id'
	mut req := http.new_request(http.Method.patch, url, data) ?
	req.header = h.header()
	mut res := req.do() ?
	mut result := ''
	if res.status_code == 200 {
		result = res.text
	} else {
		return error('could not get: $url\n$res')
	}
	return result
}

fn (mut h TaigaConnection) delete(prefix string, id int) ?bool {
	/*
	Delete Request
	Inputs:
		prefix: Taiga elements types, ex (projects, issues, tasks, ...).
		id: id of the element.
		cache: Flag to enable caching.

	Output:
		bool: True if deleted successfully.
	*/
	url := '$h.url/api/v1/$prefix/$id'
	mut req := http.new_request(http.Method.delete, url, '') ?
	req.header = h.header()
	mut res := req.do() ?
	if res.status_code == 204 {
		h.cache_drop(prefix) ? // Drop from cache, will drop too much but is ok
		return true
	} else {
		return error('Could not delete $prefix:$id')
	}
}

fn (mut h TaigaConnection) auth(url string, login string, passwd string) ?AuthDetail {
	/*
	Get authorization token by verifing username and password
	Inputs:
		url: Taiga url.
		login: Username that used in login.
		passwd: Username password.

	Output:
		response: AuthDetails struct contains auth token and other info.
	*/
	h.url = url
	if !h.url.starts_with('http') {
		if h.url.contains('http') {
			return error('url needs to start with http or not contain http. $h.url ')
		}
		h.url = 'https://$h.url'
	}

	// https://docs.taiga.io/api.html#object-auth-user-detail
	data := h.post_json_str('auth', '{
			"password": "$passwd",
			"type": "normal",
			"username": "$login"
		}',
		false) ?

	h.auth = json.decode(AuthDetail, data) ?

	return h.auth
}
