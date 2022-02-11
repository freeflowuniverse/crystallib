module httpconnection

import x.json2
// import json
import net.http
// import despiegk.crystallib.redisclient
import despiegk.crystallib.crystaljson


//see if header is empty, if yes set it
fn (mut h HTTPConnection) args_header_update(mut args Request) Request{
	//check if empty, if yes take the default
	// args.header = match args.header {
	// 	EmptyHeader { h.header_default}
	// 	http.Header { args.header }
	// }
	return args
}

fn (mut h HTTPConnection) url(mut args Request) string{
	if h.url[0].trim(" ") == ""{
		panic("cannot not havew empty url on httpconnection")
	}
	mut u := ""
	mut prefix := args.prefix.trim("/ ")
	if args.id.len>0{
		u = '$h.url_get()/$prefix/$args.id'
	}else{
		u =  '$h.url_get()/$prefix'
	}
	// println(u)
	return u
}

//
// Request{
// 	url			string
// 	prefix 		string
// 	postdata 	string
// 	cache 		bool
// 	header 		http.Header
// }
//
pub fn (mut h HTTPConnection) post_json_dict(mut args Request) ?map[string]json2.Any {
	/*
	Post Request with Json Data
	Inputs:
		cache: Flag to enable caching.
		authenticated: Flag to add authorization flag with the request.

	Output:
		response: response as dict of further json strings
	*/
	data_ := h.post_json_str(mut args)?
	data := crystaljson.json_dict_filter_any(data_, false, [], [])?
	return data
}

// Post request with json and return result as string
// this is the method which calls to the service, not intended to update data !!!
// if you want to update data make sure the cache flag is off
//
// Request{
// 	url			string
// 	prefix 		string
// 	postdata 	string
// 	cache 		bool
// 	header 		http.Header
// }
//
pub fn (mut h HTTPConnection) post_json_str(mut args Request) ?string {
	/*
	Post Request with Json Data
	Inputs:
		cache: Flag to enable caching.
		authenticated: Flag to add authorization flag with the request.

	Output:
		response: response as string.
	*/
	// Post with auth header
	args = h.args_header_update(mut args)
	args = h.cache_get(mut args)
	//if 999998 then not in cache, because otherwise can be an empty result from before
	if args.result_code == 999998 {
		args.result_code = 0
		// url := h.url(mut args)
		// mut req := http.new_request(http.Method.post, url, args.postdata) or { 
		// 	//TODO: need to implement the retry
		// 	return error("could not create http_new request.\n${args.json()}")
		// }
		// println(" --- $prefix\n$postdata")
	
		// if args.prefix.contains('auth') {
		// 	response := http.post_json('${h.url_get()}/$args.prefix', args.postdata) ?
		// 	args.result = response.text
		// } else {
		url := h.url_get()
		response := http.post_json('$url/$args.prefix', args.postdata) ?
		// response := req.do() or {
		// 	http.Response{status_code:444}
		// }
		if response.status_code == 201 || response.status_code == 200 {
			args.result = response.text
		} else if response.status_code == 444 {
			args.result = 'could not post: $url, connection issue.\n$response'
			args.result_code = 2				
		} else {
			args.result = 'could not post:$response\n${args.json()}'
			args.result_code = 5
		}
		// }
		args = h.cache_set(mut args) ?
	}
	if args.result_code>0{
		return error(args.json())
	}
	return args.result
}

pub fn (mut h HTTPConnection) get_json_dict(mut args Request) ?map[string]json2.Any{
	data_ := h.get_json_str(mut args) ?
	mut data := map[string]json2.Any{}
	if args.result_code==0{
		data = crystaljson.json_dict_filter_any(data_, false, [], [])?
	}
	return data
}

//
// Request{
// 	url			string
// 	prefix 		string
// 	postdata 	string
// 	cache 		bool
// 	header 		http.Header
// }
//
pub fn (mut h HTTPConnection) get_json_list(mut args Request) ?[]string {
	/*
	Get Request with Json Data
	Inputs:
		prefix: HTTP elements types, ex (projects, issues, tasks, ...).
		data: Json encoded data.
		cache: Flag to enable caching.

	Output:
		response: list of strings.
	*/
	mut data_ := h.get_json_str(mut args) ?
	if args.dict_key.len>0{
		data_ = crystaljson.json_dict_get_string(data_, false, args.dict_key)?
	}
	data := crystaljson.json_list(data_, false)
	return data
}


// Get request with json data and return response as string
//
// Request{
// 	url			string
// 	prefix 		string
// 	postdata 	string
// 	cache 		bool
// 	header 		http.Header
// }
//
pub fn (mut h HTTPConnection) get_json_str(mut args Request) ?string {
	/*
	Get Request with Json Data
	Inputs:
		prefix: HTTP elements types, ex (projects, issues, tasks, ...).
		data: Json encoded data.
		cache: Flag to enable caching.

	Output:
		response: response as string.
	*/
	args = h.args_header_update(mut args)
	args = h.cache_get(mut args)
	//if 999998 then not in cache, because otherwise can be an empty result from before
	if args.result_code == 999998 {
		args.result_code = 0
		url := h.url(mut args)
		mut req := http.new_request(http.Method.get, url, args.postdata) ?
		req.add_custom_header('x-disable-pagination', 'True') ?
		res := req.do() ?
		if res.status_code == 200 {
			args.result = res.text
		} else {
			args.result = 'could not get: $url\n$res'
			args.result_code = 1			
		}
		args = h.cache_set(mut args) ?
	}
	if args.result_code>0{
		return error(args.json())
	}
	return args.result
}

//
// Request{
// 	url			string
// 	prefix 		string
// 	postdata 	string
// 	cache 		bool
// 	header 		http.Header
// }
// 
// Patch Request with Json Data
// Inputs:
// 	url: part to add on url
// 	data: Json encoded data.
// Output:
// 	response: response Json2.Any map.
// 
//
pub fn (mut h HTTPConnection) edit_json(mut args Request) ?string {
	url := h.url(mut args)
	args = h.args_header_update(mut args)
	mut req := http.new_request(http.Method.patch, url, args.postdata) ?
	mut res := req.do() ?
	mut result := ''
	if res.status_code == 200 {
		result = res.text
	} else {
		return error('could not edit post: $url\n$res')
	}
	return result
}

pub fn (mut h HTTPConnection) delete(mut args Request) ?bool {
	/*
	Delete Request
	Inputs:
		url: id of the element.
		cache: Flag to enable caching.

	Output:
		bool: True if deleted successfully.
	*/
	args = h.args_header_update(mut args)
	url := h.url(mut args)
	mut req := http.new_request(http.Method.delete, url, '') ?
	mut res := req.do() ?
	if res.status_code == 204 {
		h.cache_drop(args.prefix) ? // Drop from cache, will drop too much but is ok
		return true
	} else {
		return error('Could not delete $args.prefix:$url')
	}
}
