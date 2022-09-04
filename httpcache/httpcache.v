module httpcache

import net.http
import freeflowuniverse.crystallib.redisclient

[heap]
struct HttpCache {
mut:
	redis &redisclient.Redis
}

fn init_single_cache() HttpCache {
	mut r := redisclient.core_get()
	return HttpCache{
		redis: r
	}
}

const gcache = init_single_cache()

pub fn newcache() HttpCache {
	// reuse single object
	return httpcache.gcache
}

pub fn (mut h HttpCache) getex(url string, expire int) ?string {
	// println("[+] cache: request url: " + url)
	// mut redis := redisclient.core_get()

	hit := h.redis.get('httpcache:' + url) or {
		println('[-] cache: cache miss, downloading: ' + url)

		r := http.get(url)?
		data := r.body

		status := http.status_from_int(r.status_code)
		println(r)

		if status.is_success() {
			// println("[+] cache: caching response (${data.len} bytes)")
			h.redis.set_ex('httpcache:' + url, data, expire.str()) or { eprintln(err) }
		} else {
			msg := 'error in http request.\n$data'
			println(msg)
			return error(msg)
		}
		return data
	}

	// println("[+] cache hit")
	return hit
}
