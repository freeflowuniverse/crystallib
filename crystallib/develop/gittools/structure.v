module gittools

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console

// GitStructure holds information about repositories in a memory structure.
@[heap]
pub struct GitStructure {
pub mut:
	key      string              			// Unique key for the git structure (hash of the path or default is $home/code)
	config   GitStructureConfig  			// Configuration settings
	coderoot pathlib.Path        			// Root directory for the code
	repos    map[string]&GitRepo  @[skip;str:skip]	// Map of repositories in the git structure
	loaded   bool                			// Indicates if directories have been walked and cached in redis
}

// ReposGetArgs defines the parameters for retrieving repositories based on criteria.
@[params]
pub struct ReposGetArgs {
pub mut:
	filter   string // Filter for repository names
	name     string // Specific repository name
	account  string // Git account name
	provider string // Git provider (e.g., GitHub)
	clone 	 bool 	// Clone the repo if not exists in the location
	url 	 string	// The repo URL in case the user want to clone it.
}

// Retrieve a list of repositories based on the provided arguments (filter, name, account, provider).
pub fn (mut gitstructure GitStructure) get_repos(args_ ReposGetArgs) ![]&GitRepo {
	mut args := args_
	mut res := []&GitRepo{}

	for _, repo in gitstructure.repos {
		relpath := repo.get_relative_path()!

		if args.filter != '' && relpath.contains(args.filter) {
			res << repo
			continue
		}

		if is_repo_matches(repo, args) {
			res << repo
		}
	}

	return res
}


// Retrieve a single repository based on the provided arguments
pub fn (mut gitstructure GitStructure) get_repo(args_ ReposGetArgs) !&GitRepo {
	mut args := args_
	if args.name.len == 0 {
		return error('The repository name should be passed.')
	}

	repositories := gitstructure.get_repos(args)!

	if repositories.len == 0 {
		if args.clone && args.url.len == 0 {
			return error('Cannot clone the repository, the repository URL is: ${args.url}')
		}

		if args.clone{
			return gitstructure.clone(args)!
		}
		return error('Cannot find repository with the given locator.\n${args}')
	}

	if repositories.len > 1 {
		repos := repositories.map('- ${it.account}.${it.name}').join_lines()
		return error('Found more than one repository for \n${args}\n${repos}')
	}

	return repositories[0]
}

pub fn (mut gitstructure GitStructure) clone(args ReposGetArgs) !&GitRepo {
	console.print_header("The repository '${args.name}' does not exist, cloning it from the URL: ${args.url}.")
	git_location := gitstructure.gitlocation_from_url(args.url)!
	mut repo := &GitRepo{
		provider: git_location.provider
		name: git_location.name
		account: git_location.account
		gs: gitstructure
	}

	// Set the parent directory where the repository should be cloned
	parent_dir := repo.get_parent_dir()!
	repo.name = args.name
	cmd := 'git -C ${parent_dir} clone ${args.url} ${args.name}'
	osal.exec(cmd: cmd) or {
		return error('Cannot clone the repository due to: ${err}')
	}

	repo.load()!
	console.print_green("The repository '${args.name}' cloned into ${parent_dir}.")
	return repo
}
