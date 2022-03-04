/*
METHODS NOTES
 * Our target to wrap the default http methods used in V to be cached using redis
 * By default cache enabled in all RequestArgs, if you need to disable cache, set req.cache_disable true
 *
 * Flow will be:
 * 1 - Check cache if enabled try to get result from cache
 * 2 - TODO: Check result (Need to check this part with Sameh), for now will check if not cache
 * 3 - Based on 2, do request
 * 4 - Set in cache if enabled
 * 5 - Return result data
 *
 * Suggest to use http code it will be useful, return -1 if not in cache
 * TODO: handling headers (Custom, Common)
*/

module httpconnection

import x.json2
import json
import net.http
import despiegk.crystallib.crystaljson

// FIXME:
// WHY WE NEED THESE UNKNOWN CODES !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// resultcode >0 if error
// 2 -> if req.do() return error (use 444 error)
// 5 -> if not sucess response
// resultcode = 999998 was not in cache, but we don't know on source
// resultcode = 999999 if empty (from source or was in cache)

// Build url from RequestArgs and httpconnection
fn (mut h HTTPConnection) url(args RequestArgs) string {
	mut u := '${h.url[0]}/${args.prefix.trim('/')}'
	if args.id.len > 0 {
		u += '/$args.id'
	}
	return u
}

//
fn (h HTTPConnection) check_request_cache(args RequestArgs) bool {
	return !(h.settings.cache_disable || args.cache_disable)
}

// Post request with json and return result as string
// this is the method which calls to the service, not intended to update data !!!
// if you want to update data make sure the cache flag is off
pub fn (mut h HTTPConnection) post_json_str(mut args RequestArgs) ?string {
	mut result := Result{}
	cache := h.check_request_cache(args)
	// 1 - Check cache if enabled try to get result from cache
	if cache {
		result = h.cache_get(mut args) ?
	}
	// 2 - Check result (Need to check this part with Sameh), for now will check if not cache
	if result.code == -1 {
		url := h.url(args)
		mut req := http.new_request(.post, url, args.data) or {
			return error('could not create http_new request.\n$args.json()')
		}
		response := req.do() ?
		result.code = response.status_code
		if response.status_code in success_responses {
			result.data = response.text
		} else {
			error_msg := 'failed to post request\n' + args.json() + '\nresponse\n$response'
			result.data = '{"message": "$error_msg"}'
		}
	}

	if cache {
		h.cache_set(args, result) ?
	}

	return result.data
}

pub fn (mut h HTTPConnection) get_json_dict(mut args RequestArgs) ?map[string]json2.Any {
	data_ := h.get_json_str(mut args) ?
	mut data := map[string]json2.Any{}

	data = crystaljson.json_dict_filter_any(data_, false, [], []) ?
	return data
}

pub fn (mut h HTTPConnection) get_json_list(mut args RequestArgs) ?[]string {
	/*
	Get RequestArgs with Json Data
	Inputs:
		prefix: HTTP elements types, ex (projects, issues, tasks, ...).
		data: Json encoded data.
		cache: Flag to enable caching.

	Output:
		response: list of strings.
	*/
	mut data_ := h.get_json_str(mut args) ?
	if args.dict_key.len > 0 {
		data_ = crystaljson.json_dict_get_string(data_, false, args.dict_key) ?
	}
	data := crystaljson.json_list(data_, false)
	return data
}

// Get RequestArgs with json data and return response as string
pub fn (mut h HTTPConnection) get_json_str(mut args RequestArgs) ?string {
	mut result := Result{}
	cache := h.check_request_cache(args)
	// 1 - Check cache if enabled try to get result from cache
	if cache {
		result = h.cache_get(mut args) ?
	}
	// 2 - Check result (Need to check this part with Sameh), for now will check if not cache
	if result.code == -1 {
		url := h.url(args)
		mut req := http.new_request(.get, url, args.data) or {
			return error('could not create http_new request.\n$args.json()')
		}
		response := req.do() ?
		result.code = response.status_code
		if response.status_code in success_responses {
			result.data = response.text
		} else {
			error_msg := 'failed to get request\n' + args.json() + '\nresponse\n$response'
			result.data = '{"message": "$error_msg"}'
		}
	}

	if cache {
		h.cache_set(args, result) ?
	}

	return result.data
}

fn (mut h HTTPConnection) send(mut args RequestArgs) ?Result {
	url := h.url(args)
	println(h.url)
	mut req := http.new_request(http.Method.get, url, args.data) ?
	req.add_custom_header('x-disable-pagination', 'True') ?
	res := req.do() ?
	return Result{
		code: res.status_code
		data: res.text
	}
}

pub fn (mut h HTTPConnection) edit_json(mut args RequestArgs) ?string {
	url := h.url(args)
	mut req := http.new_request(http.Method.patch, url, args.data) ?
	mut res := req.do() ?
	mut result := ''
	if res.status_code in success_responses {
		result = res.text
	} else {
		return error('could not edit post: $url\n$res')
	}
	return result
}

pub fn (mut h HTTPConnection) delete(mut args RequestArgs) ?bool {
	/*
	Delete RequestArgs
	Inputs:
		url: id of the element.
		cache: Flag to enable caching.

	Output:
		bool: True if deleted successfully.
	*/
	// args = h.args_header_update(mut args)
	url := h.url(args)
	mut req := http.new_request(http.Method.delete, url, '') ?
	mut res := req.do() ?
	if res.status_code == 204 {
		h.cache_drop(args.prefix) ? // Drop from cache, will drop too much but is ok
		return true
	} else {
		return error('Could not delete $args.prefix:$url')
	}
}

fn (mut r RequestArgs) json() string {
	return json.encode_pretty(r)
}
