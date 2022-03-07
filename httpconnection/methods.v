/*
METHODS NOTES
 * Our target to wrap the default http methods used in V to be cached using redis
 * By default cache enabled in all RequestArgs, if you need to disable cache, set req.cache_disable true
 *
 * Flow will be:
 * 1 - Check cache if enabled try to get result from cache
 * 2 - Check result
 * 3 - Do request, if needed
 * 4 - Set in cache if enabled
 * 5 - Return result
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
	if args.params.len > 0 {
		u += '?${http.url_encode_form_data(args.params)}'
	}
	return u
}

fn (mut h HTTPConnection) header(args RequestArgs) http.Header {
	return h.header_default.join(args.header)
}

// Return if request cachable, depeds on connection settings and request arguments.
fn (h HTTPConnection) is_cachable(args RequestArgs) bool {
	return !(h.settings.cache_disable || args.cache_disable)
		&& args.method in h.settings.cache_allowable_methods
}

// Core fucntion to be used in all other function
pub fn (mut h HTTPConnection) send(args RequestArgs) ?Result {
	mut result := Result{}
	is_cachable := h.is_cachable(args)
	// 1 - Check cache if enabled try to get result from cache
	if is_cachable {
		result = h.cache_get(args) ?
	}
	// 2 - Check result
	if result.code in [0, -1] {
		// 3 - Do request, if needed
		url := h.url(args)
		mut req := http.new_request(args.method, url, args.data) or {
			return error('could not create http_new request.\n$args.json()')
		}
		// joining the header from the HTTPConnection with the one from RequestArgs
		req.header = h.header()
		response := req.do() ?
		result.code = response.status_code
		result.data = response.text
	}

	// 4 - Set in cache if enabled
	if is_cachable && result.code in h.settings.cache_allowable_codes {
		h.cache_set(args, result) ?
	}

	// 5 - Return result
	return result
}

// Post request with json and return result as string
// this is the method which calls to the service, not intended to update data !!!
// if you want to update data make sure the cache flag is off
pub fn (mut h HTTPConnection) post_json_str(mut args RequestArgs) ?string {
	args.method = .post
	result := h.send(args) ?
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
	args.method = .get
	result := h.send(args) ?
	return result.data
}

pub fn (mut h HTTPConnection) edit_json(mut args RequestArgs) ?string {
	args.method = .patch
	result := h.send(args) ?
	return result.data
}

pub fn (mut h HTTPConnection) delete(mut args RequestArgs) ?bool {
	args.method = .delete
	mut is_deleted := false
	result := h.send(args) ?
	if result.code in [200, 204] {
		is_deleted = true
		// h.cache_drop_key(args) ?
	} else {
		eprintln('Could not delete $args.prefix:$h.url()')
	}
	return is_deleted
}

fn (r RequestArgs) json() string {
	return json.encode_pretty(r)
}
