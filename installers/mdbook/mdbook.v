module mdbook

import freeflowuniverse.crystallib.installers.vlang

// install mdbook will return true if it was already installed
pub fn (mut i Installer) install() ! {
	mut node := i.node
	vlang.get_install(mut node)!
	println(' - $node.name: install mdbook')
	if !node.done_exists('install_mdbook') && !node.command_exists('mdbook') {
		cmd := '
		.cargo/bin/cargo install mdbook
    	.cargo/bin/cargo install mdbook-mermaid
		'
		node.exec(cmd) or { return error('Cannot install mdbook.\n$err') }
		node.done_set('install_mdbook', 'OK')!
	}
	println(' - mdbook already done')
}
