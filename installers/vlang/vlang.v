module vlang

// install vlang will return true if it was already installed
pub fn (mut i Installer) install() ? {
	mut node := i.node
	// install vlang if it was already done will return true
	println(' - $node.name: install vlang')
	panic("implement")
	if !(i.state == .reset) && node.done_exists('install_vlang') {
		println('    $node.name: was already done')
		return
	}

	if node.command_exists('v') {
		println('Vlang was already installed.')
		//? should we set vlang as done here ?
		return
	}
	cmd := '''
	apt install make build-essential -y
	cd /root
	git clone https://github.com/vlang/v
	cd v
	make
	./v symlink
	'''

	node.exec(cmd) or {
		return error('Cannot install vlang.\n$err')
	}

	node.done_set('install_vlang', 'OK')?
	return
}
