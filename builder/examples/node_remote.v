module main

import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.installers.rust
import freeflowuniverse.crystallib.installers.mdbook
import freeflowuniverse.crystallib.installers.vlang
import freeflowuniverse.crystallib.installers.caddy
import freeflowuniverse.crystallib.installers.tailwind
import freeflowuniverse.crystallib.installers.repository

fn do() ? {
	mut builder := builder.new()

	mut node := builder.node_new(name: 'test', ipaddr: '185.206.122.151', debug: true)?

	rust.get_install(mut node) or { panic('error: $err') }
	mdbook.get_install(mut node) or { panic('error: $err') }
	vlang.get_install(mut node) or { panic('error: $err') }
	caddy.get_install(mut node) or { panic('error: $err') }
	tailwind.get_install(mut node) or { panic('error: $err') }
	repository.get_install(mut node, 'https://github.com/timurgordon/publisher_ui.git') or {
		panic('error: $err')
	}
	repository.get_install(mut node, 'https://github.com/freeflowuniverse/crystallib.git') or {
		panic('error: $err')
	}
	repository.get_install(mut node, 'https://github.com/ourworld-tsc/ourworld_books.git') or {
		panic('error: $err')
	}

	node.exec('cd code/github/timurgordon/publisher_ui; git checkout development')?
	node.exec('cd code/github/timurgordon/publisher_ui; git pull')?

	node.exec('cd code/github/freeflowuniverse/crystallib; git checkout development_publisher3_kristof')?
	node.exec('cd code/github/freeflowuniverse/crystallib; git pull')?

	node.exec('ln -sf /root/tailwindcss code/github/timurgordon/publisher_ui/tailwindcss') or {
		return error('Failed to link tailwind binary to project: $err')
	}

	node.exec('cd code/github/timurgordon/publisher_ui; sh run.sh')?
}

fn main() {
	do() or { panic(err) }
}
