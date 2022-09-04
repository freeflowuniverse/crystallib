module crystaltools

// install crystaltools will return true if it was already installed
pub fn (mut i Installer) install() ? {
	mut node := i.node
	// install crystaltools if it was already done will return true
	println(' - $node.name: install crystaltools')
	if !(i.state == .reset) && node.done_exists('install_crystaltools') {
		println('    $node.name: was already done')
		return
	}
	panic('outdated')
	node.executor.exec('cd /tmp && export TERM=xterm && curl https://raw.githubusercontent.com/freeflowuniverse/crystaltools/development/install.sh | bash') or {
		return error('Cannot install crystal tools.\n$err')
	}
	node.done_set('install_crystaltools', 'OK')?
	return
}

pub fn (mut i Installer) update() ? {
	mut node := i.node
	println(' - $node.name: update crystaltools')
	if !(i.state == .reset) && node.done_exists('install_crystaltools') {
		println('    $node.name: was already done')
		return
	}
	node.executor.exec('cd /tmp && export TERM=xterm && source /root/env.sh && ct_upgrade') or {
		return error('Cannot update crystal tools.\n$err')
	}
	node.done_set('update_crystaltools', 'OK')?
}
