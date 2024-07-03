module caddy

import freeflowuniverse.crystallib.core.pathlib
import os

fn test_new_caddyfile() {
	args := CaddyArgs{
		reset: false
		path: '/tmp/caddy'
	}
	caddy_file := new(args) or {
		assert false, 'Failed to create new CaddyFile: ${err}'
		return
	}

	assert caddy_file.path == '/tmp/caddy/Caddyfile', 'CaddyFile path mismatch'
}

fn test_reverse_proxy() {
	args := CaddyArgs{
		reset: false
		path: '/tmp/caddy'
	}
	mut caddy_file := new(args) or {
		assert false, 'Failed to create new CaddyFile: ${err}'
		return
	}

	address := Address{
		domain: 'example.com'
	}
	reverse_proxy := ReverseProxy{
		path: '/api'
		url: 'http://localhost:8080'
	}

	caddy_file.reverse_proxy(address, reverse_proxy) or {
		assert false, 'Failed to add reverse proxy: ${err}'
		return
	}

	assert caddy_file.site_blocks.len == 1, 'Expected 1 site block'
	block := caddy_file.site_blocks[0]
	assert block.addresses[0].domain == 'example.com', 'Domain mismatch'
	assert block.directives.len == 1, 'Expected 1 directive'
	assert block.directives[0].name == 'reverse_proxy', 'Directive name mismatch'
	assert block.directives[0].args == ['/api', 'http://localhost:8080'], 'Directive args mismatch'
}

fn test_file_server() {
	args := CaddyArgs{
		reset: false
		path: '/tmp/caddy'
	}
	mut caddy_file := new(args) or {
		assert false, 'Failed to create new CaddyFile: ${err}'
		return
	}

	addresses := [Address{
		domain: 'example.com'
	}]
	file_server := FileServer{
		path: '/var/www'
	}

	caddy_file.file_server(addresses, file_server) or {
		assert false, 'Failed to add file server: ${err}'
		return
	}

	assert caddy_file.site_blocks.len == 1, 'Expected 1 site block'
	block := caddy_file.site_blocks[0]
	assert block.addresses[0].domain == 'example.com', 'Domain mismatch'
	assert block.directives.len == 2, 'Expected 2 directives'
	assert block.directives[0].name == 'root', 'First directive name mismatch'
	assert block.directives[0].args == ['*', '/var/www'], 'First directive args mismatch'
	assert block.directives[1].name == 'file_server', 'Second directive name mismatch'
	assert block.directives[1].args.len == 0, 'Second directive should have no args'
}

fn test_add_site_block() {
	args := CaddyArgs{
		reset: false
		path: '/tmp/caddy'
	}
	mut caddy_file := new(args) or {
		assert false, 'Failed to create new CaddyFile: ${err}'
		return
	}

	address1 := Address{
		domain: 'example.com'
	}
	address2 := Address{
		domain: 'example.org'
	}
	directive1 := Directive{
		name: 'reverse_proxy'
		args: ['/api', 'http://localhost:8080']
	}
	directive2 := Directive{
		name: 'file_server'
		args: []
	}
	block1 := SiteBlock{
		addresses: [address1]
		directives: [directive1]
	}
	block2 := SiteBlock{
		addresses: [address1]
		directives: [directive2]
	}
	block3 := SiteBlock{
		addresses: [address2]
		directives: [directive1]
	}

	caddy_file.add_site_block(block1)
	caddy_file.add_site_block(block2)
	caddy_file.add_site_block(block3)

	assert caddy_file.site_blocks.len == 2, 'Expected 2 site blocks'

	mut block := caddy_file.site_blocks[0]
	assert block.addresses[0].domain == 'example.com', 'First block domain mismatch'
	assert block.directives.len == 2, 'First block should have 2 directives'

	block = caddy_file.site_blocks[1]
	assert block.addresses[0].domain == 'example.org', 'Second block domain mismatch'
	assert block.directives.len == 1, 'Second block should have 1 directive'
}
