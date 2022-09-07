module mdbook


import freeflowuniverse.crystallib.installers.rust


// install mdbook will return true if it was already installed
pub fn (mut i Installer) install() ? {
	mut node := i.node
	rust.install()?
	println(' - $node.name: install mdbook')
	if !node.done_exists('install_mdbook') {
		cmd:=```
		cargo install mdbook
    	cargo install mdbook-mermaid
		```
		node.exec(cmd) or {
		return error('Cannot install mdbook.\n$err')
	}		
		node.done_set('install_mdbook', 'OK')?
	}
	println(' - mdbook already done')
}

