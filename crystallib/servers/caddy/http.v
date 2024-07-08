module caddy

pub struct HTTP {
mut:
	servers map[string]Server
}

pub struct Server {
mut:
	listen []string //ports
	routes []Route
	
}

pub struct Route {
mut:
	@match []Match
	handle []Handle

}

pub struct Match {
mut:
	host []string
	path []string
}

pub struct Handle {
mut:
	handler string
	routes []Route
	providers Providers
	root string
}

pub struct Providers {
mut:
	http_basic HTTPBasic
}

pub struct HTTPBasic {
mut:
	hash string = 'bcrypt'
	accounts []Account
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
		handle: [Handle{
			handler:'subroute'
			routes: [Route {
				handle: [Handle{
					handler:'vars'
					root: args.root
				}]
			}]
		}]
	}
}

pub fn (mut http HTTP) add_basic_auth(args BasicAuth) ! {
	for key, mut server in http.servers {
		server.add_basic_auth(args.domain, args.username, args.password)
	}
}

pub fn (mut server Server) add_basic_auth(domain string, username string, password string) {
		for mut route in server.routes {
			if route.@match.any(domain in it.host) {
				route.add_basic_auth(username, password)
			}
		}
}

pub fn (mut route Route) add_basic_auth(username string, password string) {

	mut found := false
	for mut handle in route.handle {
		if handle.handler == 'subroute' {
			found = true
			handle.routes << basic_auth_route(username, password)
		}
	}
	if !found {
		route.handle << Handle {
			handler: 'subroute'
			routes: [basic_auth_route(username, password)]
		}
	}
}

fn basic_auth_route(username string, password string) Route {
	return Route {
		handle: [
			Handle {
				handler:'authentication'
				providers: Providers {
					http_basic: HTTPBasic {
						accounts: [
							Account{
								username: username
								password: password
							}
						]
					}
				}
			}
		]
	}
}

// internal function to find and return the route object in which a domain is defined
fn (http HTTP) get_domain_route(domain string) ?Route {
	for key, server in http.servers {
		for route in server.routes {
			if route.@match.any(domain in it.host) {
				return route
			}
		}
	}
	return none
}