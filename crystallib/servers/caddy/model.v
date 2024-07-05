module caddy

import net.urllib

@[heap]
pub struct CaddyFile {
pub mut:
	site_blocks []SiteBlock
	path        string = '/etc/caddy/Caddyfile'
}

pub struct SiteBlock {
pub mut:
	addresses  []Address
	directives []Directive
}

pub struct Address {
pub mut:
	url urllib.URL
	description string
}

pub struct Directive {
pub mut:
	name          string
	args          []string
	matchers      []Matcher
	subdirectives []Directive
}

pub struct Matcher {
pub mut:
	name string
	args []string
}
