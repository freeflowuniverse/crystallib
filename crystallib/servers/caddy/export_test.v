module caddy

import os

fn test_address_export() {
	addr := Address{
		description: 'Test Address'
		domain: 'example.com'
		port: 8080
	}
	expected := 'Test Address\nexample.com:8080'
	assert addr.export() == expected, 'Address export mismatch'
}

fn test_matcher_export() {
	matcher := Matcher{
		name: '@matcher'
		args: ['arg1', 'arg2']
	}
	expected := '@matcher arg1 arg2'
	assert matcher.export() == expected, 'Matcher export mismatch'
}

fn test_directive_export() {
	directive := Directive{
		name: 'reverse_proxy'
		args: ['/api', 'http://localhost:8080']
		matchers: [Matcher{
			name: '@matcher'
			args: ['arg1', 'arg2']
		}]
	}
	expected := '@matcher arg1 arg2\nreverse_proxy /api http://localhost:8080'
	assert directive.export() == expected, 'Directive export mismatch'
}

fn test_site_block_export() {
	block := SiteBlock{
		addresses: [Address{
			domain: 'example.com'
			port: 80
		}]
		directives: [
			Directive{
				name: 'root'
				args: ['*', '/var/www']
			},
			Directive{
				name: 'file_server'
				args: []
			},
		]
	}
	expected := 'example.com:80 {\nroot * /var/www\nfile_server\n}'
	assert block.export() == expected, 'SiteBlock export mismatch'
}

fn test_caddyfile_export() {
	block1 := SiteBlock{
		addresses: [Address{
			domain: 'example.com'
			port: 80
		}]
		directives: [Directive{
			name: 'root'
			args: ['*', '/var/www']
		}]
	}
	block2 := SiteBlock{
		addresses: [Address{
			domain: 'example.org'
			port: 443
		}]
		directives: [
			Directive{
				name: 'reverse_proxy'
				args: ['/api', 'http://localhost:8080']
			},
		]
	}
	mut caddy_file := CaddyFile{
		path: '/tmp/Caddyfile'
		site_blocks: [block1, block2]
	}

	expected := 'example.com:80 {\nroot * /var/www\n}\nexample.org:443 {\nreverse_proxy /api http://localhost:8080\n}'

	assert caddy_file.export()! == expected, 'CaddyFile export mismatch'
}

fn test_merge_caddyfiles() {
	block1 := SiteBlock{
		addresses: [Address{
			domain: 'example.com'
			port: 80
		}]
		directives: [Directive{
			name: 'root'
			args: ['*', '/var/www']
		}]
	}
	block2 := SiteBlock{
		addresses: [Address{
			domain: 'example.org'
			port: 443
		}]
		directives: [
			Directive{
				name: 'reverse_proxy'
				args: ['/api', 'http://localhost:8080']
			},
		]
	}
	existing_caddy_file := CaddyFile{
		path: '/tmp/caddy/Caddyfile'
		site_blocks: [block1]
	}
	new_caddy_file := CaddyFile{
		path: '/tmp/caddy/Caddyfile'
		site_blocks: [block2]
	}
	merged_file := merge_caddyfiles(existing_caddy_file, new_caddy_file)

	expected := 'example.com:80 {\nroot * /var/www\n}\nexample.org:443 {\nreverse_proxy /api http://localhost:8080\n}'

	assert merged_file.export()! == expected, 'Merged CaddyFile export mismatch'
}
