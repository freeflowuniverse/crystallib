module caddy

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.servers.caddy.security
import freeflowuniverse.crystallib.osal
import json

pub struct ReverseProxy {
pub:
	from string // path on which the url will be proxied on the domain
	to  string // url that is being reverse proxied
}

// Functions for common directives
pub fn (mut file CaddyFile) add_reverse_proxy(args ReverseProxy) ! {
}

pub struct FileServer {
pub:
	domain string // path on which the url will be proxied on the domain
	root  string // url that is being reverse proxied
}


pub fn (mut file CaddyFile) add_file_server(args FileServer) ! {
	file.apps.http.add_file_server(args)!
}

pub fn (mut file CaddyFile) add_oauth(config security.OAuthConfig) ! {
	file.apps.security.add_oauth(config)!
}

pub fn (mut file CaddyFile) add_role(name string, emails []string) ! {
	file.apps.security.add_role(name, emails)!
}

pub fn (file CaddyFile) export(path string) ! {
	// Load the existing file and merge it with the current instance
	
	mut existing_file := pathlib.get_file(path:path)!
	caddyfile_json := existing_file.read()!
	json_decoded := json.decode(CaddyFile, caddyfile_json) or {panic(err)}

	// merged_file := merge_caddyfiles(existing_file, file)

	// content := merged_file.site_blocks.map(it.export(0)).join('\n')

	content :=json.encode(file)

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
			cmd: "echo '${args.text.trim_space()}' | caddy validate --adapter caddyfile --config -"
		)!
		if job.exit_code != 0 || !job.output.trim_space().ends_with('Valid configuration') {
			return error(job.output)
		}
		return
	}
	return error('either text or path is required to validate caddyfile')
}
