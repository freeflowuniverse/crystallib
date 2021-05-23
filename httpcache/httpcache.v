module httpcache

import net.http
import despiegk.crystallib.redisclient

struct HttpCache {
mut:
	redis redisclient.Redis
}

fn init_single_cache() HttpCache {
	return HttpCache{
		redis: redisclient.connect("127.0.0.1:6379") or { redisclient.Redis{} },
	}
}

const gcache = init_single_cache()

pub fn newcache() HttpCache {
	// reuse single object
	return gcache
}

pub fn (mut h HttpCache) getex(url string, expire int) string {
	// println("[+] cache: request url: " + url)

	hit := h.redis.get("httpcache:" + url) or {
		println("[-] cache: cache miss, downloading: " + url)
		data := http.get_text(url)

		// println("[+] cache: caching response (${data.len} bytes)")
		h.redis.set_ex("httpcache:" + url, data, expire.str()) or { eprintln(err) }

		return data
	}

	// println("[+] cache hit")
	return hit
}

