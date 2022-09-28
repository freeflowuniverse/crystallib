module golang

// install golang will return true if it was already installed
pub fn (mut i Installer) install() ? {
	mut node := i.node
	// install golang if it was already done will return true
	println(' - $node.name: install golang')
	if !(i.state == .reset) && node.done_exists('install_golang') {
		println('    $node.name: was already done')
		return
	}

	if node.command_exists('go') {
		println('Golang was already installed.')
		node.done_set('install_golang', 'OK')?
		return
	}

	if node.platform == builder.PlatformType.osx {
		cmd := '''
		cd /tmp
		rm -f go1.19*
		curl -L hhttps://go.dev/dl/go1.19.1.darwin-amd64.pkg > go1.19.1.darwin-amd64.pkg
		echo need to implement
		exit 1 
		echo 'export PATH=$PATH:/usr/local/go/bin' >> $HOME/.profile
		'''
	} else if node.platform == builder.PlatformType.ubuntu {
		cmd := '''
		cd /tmp
		rm -f go1.19.1.linux-amd64.tar.gz
		curl -L https://go.dev/dl/go1.19.1.linux-amd64.tar.gz > go1.19.1.linux-amd64.tar.gz
		rm -rf /usr/local/go
		tar -C /usr/local -xzf go1.19.1.linux-amd64.tar.gz
		#TODO: should use a replacement command rather than just adding e.g. use line editor
		echo 'export PATH=$PATH:/usr/local/go/bin' >> $HOME/.profile
		'''
	} else {
		panic('only ubuntu and osx supported for now')
	}	

	node.exec(cmd) or {
		return error('Cannot install golang.\n$err')
	}

	node.done_set('install_golang', 'OK')?
	return
}
