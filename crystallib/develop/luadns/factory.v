module luadns

import freeflowuniverse.crystallib.develop.gittools

struct LuaDNS {
pub mut:
	url     string
	configs []DNSConfig
}

// returns the path of the fetched repo
pub fn load(url string) !LuaDNS {
	repo_path := gittools.code_get(
		url: url
		pull: true
	)!

	return LuaDNS{
		url: url
		configs: parse_dns_configs(repo_path)!
	}
}
