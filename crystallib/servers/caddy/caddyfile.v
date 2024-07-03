module caddy

import freeflowuniverse.crystallib.core.pathlib

@[params]
pub struct CaddyArgs {
pub mut:
	reset bool   = true
	path  string = '/etc/caddy'
}

pub fn new(args CaddyArgs) !CaddyFile {
	mut file := CaddyFile{
		path: '${args.path}/Caddyfile'
	}
	return file
}

pub struct ReverseProxy {
pub:
	path string // path on which the url will be proxied on the domain
	url  string // url that is being reverse proxied
}

// Functions for common directives
pub fn (mut file CaddyFile) reverse_proxy(address Address, reverse_proxy ReverseProxy) ! {
	mut block := SiteBlock{
		addresses: [address]
	}
	directive := Directive{
		name: 'reverse_proxy'
		args: [reverse_proxy.path, reverse_proxy.url]
	}
	block.directives << directive
	file.add_site_block(block)
}

pub struct FileServer {
pub:
	path string
}

pub fn (mut file CaddyFile) file_server(addresses []Address, file_server FileServer) ! {
	mut block := SiteBlock{
		addresses: addresses
	}
	directive := Directive{
		name: 'root'
		args: ['*', file_server.path]
	}
	block.directives << directive
	block.directives << Directive{
		name: 'file_server'
		args: []
	}
	file.add_site_block(block)
}

// Add a site block in a smart manner
pub fn (mut file CaddyFile) add_site_block(new_block SiteBlock) {
	for mut block in file.site_blocks {
		if block.addresses.len == 0 && new_block.addresses.len == 0 {
			for directive in new_block.directives {
				if !block.directives.any(it.name == directive.name && it.args == directive.args) {
					block.directives << directive
				}
			}
			return
		}
		if block.addresses.any(it.domain == new_block.addresses[0].domain) {
			// Add directives to the existing block, avoiding duplicates
			for directive in new_block.directives {
				if !block.directives.any(it.name == directive.name && it.args == directive.args) {
					block.directives << directive
				}
			}
			return
		}
	}
	// Add new block if no existing block matches the domain
	file.site_blocks << new_block
}
