module httpcache

import net.http
import despiegk.crystallib.redisclient

struct HttpCache {
mut:
	redis redisclient.Redis
}

pub fn newcache() HttpCache {
	mut c := HttpCache{}
	c.redis = redisclient.connect("127.0.0.1:6379") or { redisclient.Redis{} }

	return c
}

pub fn (mut h HttpCache) getex(url string, expire int) string {
	println("[+] cache: request url: " + url)

	hit := h.redis.get("httpcache:" + url) or {
		println("[-] cache: cache miss, downloading: " + url)
		data := http.get_text(url)

		println("[+] cache: caching response (${data.len} bytes)")
		h.redis.set_ex("httpcache:" + url, data, expire.str()) or { eprintln(err) }

		return data
	}

	println("[+] cache hit")
	return hit
}

