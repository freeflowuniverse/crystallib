module caddy

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.servers.caddy.security
import freeflowuniverse.crystallib.osal
import arrays
import json

pub struct ReverseProxy {
pub:
	from string // path on which the url will be proxied on the domain
	to  string // url that is being reverse proxied
}

// Functions for common directives
pub fn (mut file CaddyFile) add_reverse_proxy(args ReverseProxy) ! {
	file.apps.http.add_reverse_proxy(args)!
}

pub struct FileServer {
pub:
	domain string // path on which the url will be proxied on the domain
	root  string // url that is being reverse proxied
}


pub fn (mut file CaddyFile) add_file_server(args FileServer) ! {
	file.apps.http.add_file_server(args)!
}

pub struct BasicAuth {
pub:
	domain string
	username string
	password string
}

pub fn (mut file CaddyFile) add_basic_auth(args BasicAuth) ! {
	file.apps.http.add_basic_auth(args)!
}

// pub fn (mut file CaddyFile) add_oauth(config security.OAuthConfig) ! {
// 	file.apps.security.add_oauth(config)!
// }

// pub fn (mut file CaddyFile) add_role(name string, emails []string) ! {
// 	file.apps.security.add_role(name, emails)!
// }

pub fn (file CaddyFile) export(path_ string) ! {	
	// Load the existing file and merge it with the current instance
	mut path := path_
	if !path.ends_with('.json') {
		path = '${path}.json'
	}
	mut existing_file := pathlib.get_file(
		path:path
		create: true
	)!
	
	caddyfile_json := existing_file.read()!

	merged_file := if caddyfile_json != '' {
		existing_object := json.decode(CaddyFile, caddyfile_json) or {panic(err)}
		merge_caddyfiles(existing_object, file)
	} else {file}


	content := json.encode(merged_file)

	validate(text: content) or { return error('Caddyfile is not valid\n${err}') }
	mut json_file := pathlib.get_file(path: path)!
	json_file.write(content)!
}

pub struct ValidateArgs {
	text string
	path string
}

pub fn validate(args ValidateArgs) ! {
	if args.text != '' && args.path != '' {
		return error('either text or path is required to validate caddyfile, cant be both')
	}
	if args.text != '' {
		job := osal.exec(
			cmd: "echo '${args.text.trim_space()}' | caddy validate --config -"
		)!
		if job.exit_code != 0 || !job.output.trim_space().ends_with('Valid configuration') {
			return error(job.output)
		}
		return
	}
	return error('either text or path is required to validate caddyfile')
}


pub fn merge_caddyfiles(file1 CaddyFile, file2 CaddyFile) CaddyFile {
	apps := Apps {
		http: merge_http(file1.apps.http, file2.apps.http)
	}
	
	return CaddyFile {
		apps: apps
	}
}

pub fn merge_http(http1 HTTP, http2 HTTP) HTTP {
	mut servers := http1.servers.clone()
	
	for key2, server2 in http2.servers {
		if key2 in servers {
			servers[key2] = merge_servers(servers[key2], server2)
		} else {
			servers[key2] = server2
		}
	}
	return HTTP{servers: servers}
}

pub fn merge_servers(server1 Server, server2 Server) Server {
	mut listen := server1.listen.clone()

	for port in server2.listen {
		if !listen.contains(port) {
			listen << port
		}
	}

	mut routes := server1.routes.clone()
	
	for route2 in server2.routes {
		// only add routes for hosts that have not been defined
		route2_hosts := arrays.flatten[string](route2.@match.map(it.host.map(it)))
		routes_hosts := arrays.flatten[string](routes.map(arrays.flatten[string](it.@match.map(it.host.map(it)))))
		if !route2_hosts.any(it in routes_hosts) {
			routes << route2
		}
	}
	return Server{
		listen: listen
		routes: routes
	}
}