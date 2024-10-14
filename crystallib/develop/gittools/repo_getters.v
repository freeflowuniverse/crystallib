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

// Check if a repository exists based on the provided arguments
pub fn (mut gitstructure GitStructure) repo_exists(args ReposGetArgs) !bool {
	res := gitstructure.get_repos(args)!
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
	return gitstructure.get_repo(name: l.name, account: l.account, provider: l.provider)!
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

	mut r := gs.get_repo(provider: gl.provider, account: gl.account, name: gl.name)!
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
