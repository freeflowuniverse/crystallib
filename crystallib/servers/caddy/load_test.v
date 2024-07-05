module caddy

import os
import freeflowuniverse.crystallib.core.pathlib

const testdata_dir = '${os.dir(@FILE)}/testdata'

fn test_load_caddyfile() ! {
	file := pathlib.get_file(path:'${testdata_dir}/Caddyfile')!
	object := load_caddyfile(file.path)!

	assert object.site_blocks.len > 0

	block_0 := object.site_blocks[0]
	assert block_0.addresses.len == 0
	assert block_0.directives.len == 4
	assert block_0.directives.map(it.name) == ['https_port', 'order', 'order', 'security']

	security_block := block_0.directives[3]
	assert security_block.subdirectives.len == 3
	assert security_block.subdirectives.map(it.name) == ['oath', 'authentication', 'authorization']
	panic(security_block.subdirectives)
	
}
// 	caddyfile_content := '
// example.com:80 {
// 	root * /var/www
// 	file_server
// }

// example.org:443 {
// 	reverse_proxy /api http://localhost:8080
// }'

// 	temp_path := './temp_caddyfile'
// 	os.write_file(temp_path, caddyfile_content)!

// 	defer {
// 		os.rm(temp_path) or { panic(err) }
// 	}

// 	caddyfile := load_caddyfile(temp_path)!
// 	assert caddyfile.site_blocks.len == 2

// 	block1 := caddyfile.site_blocks[0]
// 	assert block1.addresses.len == 1
// 	assert block1.addresses[0].domain == 'example.com'
// 	assert block1.addresses[0].port == 80
// 	assert block1.directives.len == 2
// 	assert block1.directives[0].name == 'root'
// 	assert block1.directives[0].args == ['*', '/var/www']
// 	assert block1.directives[1].name == 'file_server'
// 	assert block1.directives[1].args == []

// 	block2 := caddyfile.site_blocks[1]
// 	assert block2.addresses.len == 1
// 	assert block2.addresses[0].domain == 'example.org'
// 	assert block2.addresses[0].port == 443
// 	assert block2.directives.len == 1
// 	assert block2.directives[0].name == 'reverse_proxy'
// 	assert block2.directives[0].args == ['/api', 'http://localhost:8080']
// }

// fn test_load_caddyfile_with_comments_and_empty_lines() ! {
// 	caddyfile_content := '
// # This is a comment
// example.com:80 {
// 	# Another comment
// 	root * /var/www
// 	file_server

// 	# Comment inside block
// }

// # One more comment
// example.org:443 {
// 	reverse_proxy /api http://localhost:8080
// }'

// 	temp_path := './temp_caddyfile_with_comments'
// 	os.write_file(temp_path, caddyfile_content)!

// 	defer {
// 		os.rm(temp_path) or { panic(err) }
// 	}

// 	caddyfile := load_caddyfile(temp_path)!
// 	assert caddyfile.site_blocks.len == 2

// 	block1 := caddyfile.site_blocks[0]
// 	assert block1.addresses.len == 1
// 	assert block1.addresses[0].domain == 'example.com'
// 	assert block1.addresses[0].port == 80
// 	assert block1.directives.len == 2
// 	assert block1.directives[0].name == 'root'
// 	assert block1.directives[0].args == ['*', '/var/www']
// 	assert block1.directives[1].name == 'file_server'
// 	assert block1.directives[1].args == []

// 	block2 := caddyfile.site_blocks[1]
// 	assert block2.addresses.len == 1
// 	assert block2.addresses[0].domain == 'example.org'
// 	assert block2.addresses[0].port == 443
// 	assert block2.directives.len == 1
// 	assert block2.directives[0].name == 'reverse_proxy'
// 	assert block2.directives[0].args == ['/api', 'http://localhost:8080']
// }

// fn test_load_caddyfile_with_incomplete_block() ! {
// 	caddyfile_content := '
// example.com:80 {
// 	root * /var/www
// 	file_server
// }

// example.org:443 {
// 	reverse_proxy /api http://localhost:8080'

// 	temp_path := './temp_caddyfile_incomplete'
// 	os.write_file(temp_path, caddyfile_content)!

// 	defer {
// 		os.rm(temp_path) or { panic(err) }
// 	}

// 	caddyfile := load_caddyfile(temp_path)!
// 	assert caddyfile.site_blocks.len == 2

// 	block1 := caddyfile.site_blocks[0]
// 	assert block1.addresses.len == 1
// 	assert block1.addresses[0].domain == 'example.com'
// 	assert block1.addresses[0].port == 80
// 	assert block1.directives.len == 2
// 	assert block1.directives[0].name == 'root'
// 	assert block1.directives[0].args == ['*', '/var/www']
// 	assert block1.directives[1].name == 'file_server'
// 	assert block1.directives[1].args == []

// 	block2 := caddyfile.site_blocks[1]
// 	assert block2.addresses.len == 1
// 	assert block2.addresses[0].domain == 'example.org'
// 	assert block2.addresses[0].port == 443
// 	assert block2.directives.len == 1
// 	assert block2.directives[0].name == 'reverse_proxy'
// 	assert block2.directives[0].args == ['/api', 'http://localhost:8080']
// }
