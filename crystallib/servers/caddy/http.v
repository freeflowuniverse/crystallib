module caddy

pub struct HTTP {
mut:
	servers map[string]Server
}

pub struct Server {
mut:
	listen []string = [":443"]//ports
	routes []Route
	
}

pub struct Route {
mut:
	@match ?[]Match
	handle []Handle
	terminal bool = true

}

pub struct Match {
mut:
	host []string
	path ?[]string
}

pub struct Handle {
mut:
	handler string
	routes ?[]Route
	providers Providers @[omitempty]
	root ?string
	hide ?[]string
	upstreams ?[]map[string]string
}

pub struct Providers {
mut:
	http_basic HTTPBasic
}

pub struct HTTPBasic {
mut:
	hash Hash
	accounts []Account
	hash_cache map[string]string
}

pub struct Hash {
	algorithm string
}

pub struct Account {
	username string
	password string
}

pub fn (mut http HTTP) add_file_server(args FileServer) ! {
	if 'srv0' !in http.servers {
		http.servers['srv0'] = Server{}
	}

	http.servers['srv0'].routes << Route {
		@match: [Match{
			host: [args.domain]
		}]
		handle: [
			Handle{
				handler:'subroute'
				routes: [Route {
					handle: [
						Handle{
							handler:'vars'
							root: args.root
						},
						Handle{
							handler:'file_server'
							hide: ["/etc/caddy/Caddyfile"]
						}
					]
				}]
			}
		]
	}
}

pub fn (mut http HTTP) add_reverse_proxy(args ReverseProxy) ! {
	if 'srv0' !in http.servers {
		http.servers['srv0'] = Server{}
	}

	http.servers['srv0'].routes << Route {
		@match: [Match{
			host: [args.to]
		}]
		handle: [
			Handle{
				handler:'subroute'
				routes: [Route {
					handle: [
						reverse_proxy_handle(args.to, args.from)!
					]
				}]
			}
		]
	}
}

pub fn (mut http HTTP) add_basic_auth(args BasicAuth) ! {
	for key, mut server in http.servers {
		server.add_basic_auth(args.domain, args.username, args.password)!
	}
}

pub fn (mut server Server) add_basic_auth(domain string, username string, password string) ! {
		for mut route in server.routes {
			if route.@match or {return}.any(domain in it.host) {
				route.add_basic_auth(username, password)!
			}
		}
}

pub fn (mut route Route) add_basic_auth(username string, password string) ! {

	mut found := false
	for mut handle in route.handle {
		if handle.handler == 'subroute' {
			found = true
			mut routes := handle.routes or {continue}.clone()
			for mut r in routes {
				mut inserted := false
				for i, h in r.handle {
					// for some reason this needs to be placed after vars handler
					if h.handler == 'vars' {
						r.handle.insert(i+1, basic_auth_handle(username, password)!)
						inserted = true
					}
				}
				if !inserted {
					r.handle.prepend(basic_auth_handle(username, password)!)
				}
			}
			handle.routes = routes.clone()
		}
	}
	if !found {
		route.handle << Handle {
			handler: 'subroute'
			routes: [Route {
				handle: [basic_auth_handle(username, password)!]
			}]
		}
	}
}

fn basic_auth_handle(username string, password string) !Handle {
	return Handle {
		handler:'authentication'
		providers: Providers {
			http_basic: HTTPBasic {
				accounts: [
					Account{
						username: username
						password: hash_password(password)!
					}
				]
				hash: Hash{'bcrypt'}
			}
		}
	}
}

fn reverse_proxy_handle(to string, from string) !Handle {
	return Handle {
		handler:'reverse_proxy'
		upstreams: [
			{'dial': '${from}'}
		]
	}
}