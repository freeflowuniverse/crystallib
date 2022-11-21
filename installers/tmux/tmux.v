module tmux

// install tmux will return true if it was already installed
pub fn (mut i Installer) install() ! {
	mut node := i.node
	// install tmux if it was already done will return true
	println(' - $node.name: install tmux')
	if !(i.state == .reset) && node.done_exists('install_tmux') {
		println('    $node.name: was already done')
		return
	}

	if node.cmd_exists('tmux') {
		println('tmux was already installed.')
	}

	// installs tmux and answers first prompt yes
	node.exec('yes Y | apt install tmux') or { return error('Cannot install tmux.\n$err') }

	node.done_set('install_tmux', 'OK')!
	return
}
