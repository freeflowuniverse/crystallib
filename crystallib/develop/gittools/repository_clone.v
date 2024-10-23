module gittools


import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal

// Clones a new repository into the git structure based on the provided arguments.
pub fn (mut gitstructure GitStructure) clone(url string) !&GitRepo {
	
	console.print_header("Git clone from the URL: ${url}.")
	git_location := gitstructure.gitlocation_from_url(url)!
	mut repo := &GitRepo{
		provider: git_location.provider
		name: git_location.name
		account: git_location.account
		gs: gitstructure
		status_remote: GitRepoStatusRemote{
			url: url
		}
	}

	// Set the parent directory where the repository should be cloned.
	parent_dir := repo.get_parent_dir()!
	
	cmd := 'cd ${parent_dir} && git clone ${repo.get_repo_url()!} ${repo.name}'
	osal.exec(cmd: cmd) or {
		return error('Cannot clone the repository due to: \n${err}')
	}

	repo.load()!

	console.print_green("The repository '${repo.name}' cloned into ${parent_dir}.")
	
	return repo
}
