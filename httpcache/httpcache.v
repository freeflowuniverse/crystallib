module httpcache

import net.http
import redisclient

struct HttpCache {
mut:
	redis redisclient.Redis
}

fn init_single_cache() HttpCache {
	return HttpCache{
		redis: redisclient.get_local() or { redisclient.Redis{} }
	}
}

const gcache = init_single_cache()

pub fn newcache() HttpCache {
	// reuse single object
	return httpcache.gcache
}

pub fn (mut h HttpCache) getex(url string, expire int) ?string {
	// println("[+] cache: request url: " + url)

	hit := h.redis.get('httpcache:' + url) or {
		println('[-] cache: cache miss, downloading: ' + url)
		
		r := http.get(url) ?
		data := r.text

		status := http.status_from_int(r.status_code)
		println(r)

		if status.is_success(){
			// println("[+] cache: caching response (${data.len} bytes)")
			h.redis.set_ex('httpcache:' + url, data, expire.str()) or { eprintln(err) }
		}else{
			msg := "error in http request.\n$data"
			println(msg)
			return error(msg)
		}
		return data
	}

	// println("[+] cache hit")
	return hit
}

