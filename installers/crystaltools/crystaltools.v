module builder

// install crystaltools if it was already done will return true
pub fn (mut node Node) crystaltools_install() ?bool {
	println(' - $node.name: install crystaltools')
	if node.done_exists('install_crystaltools') {
		println('    $node.name: was already done')
		return true
	}
	node.executor.exec('cd /tmp && export TERM=xterm && curl https://raw.githubusercontent.com/freeflowuniverse/crystaltools/development/install.sh | bash') or {
		return error('Cannot install crystal tools.\n$err')
	}
	node.done_set('install_crystaltools', 'OK')?
	return false
}

struct CrystalUpdateArgs {
	reset bool
}

pub fn (mut node Node) crystaltools_update(args CrystalUpdateArgs) ? {
	println(' - $node.name: update crystaltools')
	if !args.reset && node.done_exists('update_crystaltools') {
		println('    $node.name: was already done')
		return
	}
	node.executor.exec('cd /tmp && export TERM=xterm && source /root/env.sh && ct_upgrade') or {
		return error('Cannot update crystal tools.\n$err')
	}
	node.done_set('update_crystaltools', 'OK')?
}
