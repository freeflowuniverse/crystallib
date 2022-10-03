module repository

// install repository will return true if it was already installed
pub fn (mut i Installer) install(repo_url string) ? {
	mut node := i.node
	split_url := repo_url.split('/')
	mut repo_name := split_url[split_url.len - 1].trim_string_right('.git')
	mut repo_owner := split_url[split_url.len - 2]
	// install repository if it was already done will return true
	println(' - $node.name: install repository: $repo_owner/$repo_name')
	if !(i.state == .reset) && node.done_exists('install_$repo_owner/$repo_name') {
		println('    $node.name: $repo_owner/$repo_name was already done')
		return
	}

	// TODO: check if repo exists
	// if node.command_exists('v') {
	// 	println('repository was already installed.')
	// 	return
	// }

	node.exec('mkdir -p code/github/$repo_owner') or {
		return error('could not create directory code/github:\n$err')
	}

	cmd := 'git clone $repo_url code/github/$repo_owner/$repo_name'

	node.exec(cmd) or { return error('Cannot install repository: $repo_owner/$repo_name \n $err') }

	node.done_set('install_$repo_owner/$repo_name', 'OK')?
	return
}
