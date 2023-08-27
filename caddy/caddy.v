module caddy

import os

pub fn run_reverse_proxy(domain string, port int) {
	cmd := 'caddy reverse-proxy --from ${domain} --to :${port}'
	res := os.execute(cmd)
	println(res.output)
}
