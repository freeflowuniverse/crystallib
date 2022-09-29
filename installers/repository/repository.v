module repository

// install repository will return true if it was already installed
pub fn (mut i Installer) install(repo_url string) ? {
	mut node := i.node
	// install repository if it was already done will return true
	println(' - $node.name: install repository: $repo_url')
	if !(i.state == .reset) && node.done_exists('install_$repo_url') {
		println('    $node.name: $repo_url was already done')
		return
	}

	// TODO: check if repo exists
	// if node.command_exists('v') {
	// 	println('repository was already installed.')
	// 	return
	// }
	
	cmd := 'git clone $repo_url'

	node.exec(cmd) or {
		return error('Cannot install repository: $repo_url.\n$err')
	}

	node.done_set('install_$repo_url', 'OK')?
	return
}
