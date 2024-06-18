module caddy

@[heap]
pub struct Address {
pub mut:
	domain      string // e.g. www.ourworld.tf
	port        int = 443 // if not filled in then 443
	description string
}

@[heap]
pub struct Backend {
pub mut:
	addr        string = 'localhost'
	port        int    = 8000
	description string // always optional
}

pub struct SiteBlock {
pub mut:
	addresses       []Address
	reverse_proxy []ReverseProxy
	file_server []FileServer
}

pub struct FileServer {
	path string
}

pub struct ReverseProxy {
pub:
	path string // path on with the url will be proxied on the domain
	url  string // url that is being reverse proxied
}
