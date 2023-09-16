module crystaltools
import freeflowuniverse.crystallib.osal
// install crystaltools will return true if it was already installed
pub fn  install() ! {

	// install crystaltools if it was already done will return true
	println(' - ${node.name}: install crystaltools')
	if !(i.state == .reset) && osal.done_exists('install_crystaltools') {
		println('    ${node.name}: was already done')
		return
	}
	panic('outdated')
	osal.exec_silent('cd /tmp && export TERM=xterm && curl https://raw.githubusercontent.com/freeflowuniverse/crystaltools/development/install.sh | bash') or {
		return error('Cannot install crystal tools.\n${err}')
	}
	osal.done_set('install_crystaltools', 'OK')!
	return
}

pub fn  update() ! {

	println(' - ${node.name}: update crystaltools')
	if !(i.state == .reset) && osal.done_exists('install_crystaltools') {
		println('    ${node.name}: was already done')
		return
	}
	osal.exec_silent('cd /tmp && export TERM=xterm && source /root/env.sh && ct_upgrade') or {
		return error('Cannot update crystal tools.\n${err}')
	}
	osal.done_set('update_crystaltools', 'OK')!
}
