module caddy

import freeflowuniverse.crystallib.core.pathlib

@[heap]
pub struct CaddyFile {
pub mut:
	site_blocks []SiteBlock
	path        pathlib.Path
}

@[params]
pub struct CaddyArgs {
pub mut:
	reset bool   = true
	path  string = '/etc/caddy'
}

pub fn new(args CaddyArgs) !CaddyFile {
	mut file := CaddyFile{
		path: pathlib.get_file(path: '${args.path}/Caddyfile', create: true)!
	}
	return file
}

pub fn (mut file CaddyFile) reverse_proxy(block SiteBlock) ! {
	file.site_blocks << block
}

pub fn (file CaddyFile) export() !string {
	content := file.site_blocks.map(it.export()).join('\n')
	return content
}

// generates config for site in caddyfile
pub fn (block SiteBlock) export() string {
	mut str := block.addresses.map(it.export()).join(', ')
	return '${str} {\n${block.reverse_proxy.map(it.export()).join('\n')}\n${block.file_server.map(it.export()).join('\n')}\n}'
}

pub fn (fs FileServer) export() string {
	return 'root * ${fs.path}\nfile_server'
}

pub fn (addr Address) export() string {
	mut str := ''
	if addr.description != '' {
		str = '${addr.description}\n'
	}

	if addr.domain != '' {
		str += '${addr.domain}'
	}

	if addr.port != 0 {
		str += ':${addr.port}'
	}
	return str
}

pub fn (proxy ReverseProxy) export() string {
	mut str := 'reverse_proxy'
	if proxy.path != '' {
		str += ' ${proxy.path}'
	}
	str += ' ${proxy.url}'
	return str
}
