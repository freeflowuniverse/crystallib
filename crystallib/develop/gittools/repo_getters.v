module gittools

// Helper method to convert `ReposGetArgs` to a string representation
pub fn (a ReposGetArgs) str() string {
	mut out := ''
	if a.filter.len > 0 {
		out += 'filter:${a.filter} '
	}
	if a.name.len > 0 {
		out += 'name:${a.name} '
	}
	if a.account.len > 0 {
		out += 'account:${a.account} '
	}
	if a.provider.len > 0 {
		out += 'provider:${a.provider} '
	}
	return out.trim_space()
}

// Retrieve a list of repositories based on the provided arguments (filter, name, account, provider)
pub fn (mut gitstructure GitStructure) repos_get(args_ ReposGetArgs) ![]&GitRepo {
	mut args := ReposGetArgs{
		...args_
	}
	mut res := []&GitRepo{}

	// Loop through repositories and filter based on the provided arguments
	for _, r in gitstructure.repos {
		relpath := r.path_relative()!
		// Check filter first
		if args.filter != '' && relpath.contains(args.filter) {
			res << r
			continue
		}

		// Filter by name, account, and provider
		if (args.name.len == 0 || args.name.to_lower() == r.name.to_lower())
			&& (args.account.len == 0 || args.account.to_lower() == r.account.to_lower())
			&& (args.provider.len == 0 || args.provider.to_lower() == r.provider.to_lower()) {
			res << r
		}
	}

	return res
}

// Retrieve a single repository based on the provided arguments
pub fn (mut gitstructure GitStructure) repo_get(args ReposGetArgs) !&GitRepo {
	if args.name.len == 0 {
		return error('The repository name should be passed.')
	}

	res := gitstructure.repos_get(args)!
	// res[0].vscode()
	// res[0].url_ssh_get()
	// res[0].path()
	// res[0].need_push()

	// res[0]

	if res.len == 0 {
		return error('Cannot find repository with the given locator.\n${args}')
	}
	if res.len > 1 {
		repos := res.map('- ${it.account}.${it.name}').join_lines()
		return error('Found more than one repository for \n${args}\n${repos}')
	}
	// mut repo = 
	// repo. 
	return res[0] or { panic('bug: unexpected empty result') }
}

// Check if a repository exists based on the provided arguments
pub fn (mut gitstructure GitStructure) repo_exists(args ReposGetArgs) !bool {
	res := gitstructure.repos_get(args)!
	if res.len == 0 {
		return false
	}
	if res.len > 1 {
		return error('Found more than one repository with the given locator.\n${args}')
	}
	return true
}

// Retrieve a repository based on the GitLocation
pub fn (mut gitstructure GitStructure) repo_get_from_locator(l GitLocation) !&GitRepo {
	return gitstructure.repo_get(name: l.name, account: l.account, provider: l.provider)!
}

// Check if a repository exists based on the GitLocation
pub fn (mut gitstructure GitStructure) repo_exists_from_locator(l GitLocation) !bool {
	return gitstructure.repo_exists(name: l.name, account: l.account, provider: l.provider)!
}

// Get repository from URL, pull if necessary, and return the path
pub fn (mut gs GitStructure) code_get(args GSCodeGetFromUrlArgs) !string {
	mut gl := GitLocation{}

	// Get the GitLocation from path or URL
	if args.path.len > 0 {
		gl = gs.gitlocation_from_path(args.path)!
	}
	if args.url.len > 0 {
		gl = gs.gitlocation_from_url(args.url)!
	}

	// Check if the repository exists; if not, clone it
	if !gs.repo_exists(provider: gl.provider, account: gl.account, name: gl.name)! {
		panic('Repository does not exist, cloning is not yet implemented.')
	}

	mut r := gs.repo_get(provider: gl.provider, account: gl.account, name: gl.name)!
	// println(r)

	// Handle reload, reset, branch, and tag if specified
	if args.reload {
		panic('Reload functionality is not yet implemented.')
	}
	if args.reset {
		panic('Reset functionality is not yet implemented.')
	}
	if args.branch.len > 0 {
		panic('Branch handling is not yet implemented.')
	}
	if args.tag.len > 0 {
		panic('Tag handling is not yet implemented.')
	}
	if args.pull {
		panic('Pull functionality is not yet implemented.')
	}

	return gl.patho()!.path
}
