module caddy


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


[params]
pub struct AddSiteBlockArgs {
	overwrite bool
}

// Add a site block in a smart manner
pub fn (mut file CaddyFile) add_site_block(new_block SiteBlock, args AddSiteBlockArgs) {
	

	// if new_block.addresses.any(it == file.site_blocks.map(it.addresses))

	for mut block in file.site_blocks {
		
		block_urls := block.addresses.map(it.url.str().trim_space())
		new_block_urls := new_block.addresses.map(it.url.str().trim_space())
		if new_block_urls.any(it in block_urls) {
			return
		}

		if block_urls.len == 0 && new_block_urls.len == 0 {
			return
		}
	}
	
	// Add new block if no existing block matches the domain
	file.site_blocks << new_block
	// 	if new_block.addresses.len == 0 {
	// 		if block.addresses.len == 0 {
	// 			// for directive in new_block.directives {
	// 			// 	if !block.directives.any(it.name == directive.name && it.args == directive.args) {
	// 			// 		block.directives << directive
	// 			// 	}
	// 			// }
	// 			if !args.overwrite {
	// 				return
	// 			}
	// 		}
	// 	}
	// 	else if block.addresses.any(it.domain == new_block.addresses[0].domain) {
	// 		// Add directives to the existing block, avoiding duplicates
	// 		if !args.overwrite {
	// 				return
	// 			}
	// 		// for directive in new_block.directives {
	// 		// 	if !block.directives.any(it.name == directive.name && it.args == directive.args) {
	// 		// 		block.directives << directive
	// 		// 	}
	// 		// }
	// 		// return
	// 	}
	// }
}
