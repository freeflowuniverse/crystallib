module gittools

// import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.ui.console
import os

// Reload all information from disk & remote SSH.
// Use kwarg: reload: true to ensure everything is reloaded.
pub fn (mut gitstructure GitStructure) load(args StatusUpdateArgs) ! {
	mut processed_paths := []string{}
	gitstructure.load_recursive(gitstructure.coderoot.path, args, mut processed_paths)!
}

// Load git structure recursively from the specified path.
fn (mut gitstructure GitStructure) load_recursive(path string, args StatusUpdateArgs, mut processed_paths []string) ! {
	console.print_debug('gitstructure recursive load: ${path}')

	path_object := pathlib.get(path)
	relpath := path_object.path_relative(gitstructure.coderoot.path)!

	// Limit the recursion depth to avoid excessive loading
	if relpath.count('/') > 4 {
		return
	}

	// List items in the current directory
	items := os.ls(path) or { return error('cannot load gitstructure because cannot find ${path}') }

	for item in items {
		current_path := os.join_path(path, item)

		// Check if the current item is a directory
		if os.is_dir(current_path) {
			if os.exists(os.join_path(current_path, '.git')) {
				// Initialize repository from the current path
				mut repo := gitstructure.repo_init_from_path_(current_path)!
				repo.status_update(reload: args.reload)!

				key_ := repo.get_key()
				path_ := repo.get_path()!

				if processed_paths.contains(key_) || processed_paths.contains(path_) {
					return error('loading of repo failed due to duplication.\npath: ${path_}\nkey: ${key_}')
				}
				// Track processed paths
				processed_paths << path_
				processed_paths << key_
				gitstructure.repos[key_] = &repo
				continue
			}
			// Skip hidden directories
			if item.starts_with('.') || item.starts_with('_') {
				continue
			}
			// Recurse into subdirectories
			gitstructure.load_recursive(current_path, args, mut processed_paths)!
		}
	}
}

// Reset the cache for the current git structure
pub fn (mut gitstructure GitStructure) cachereset() ! {
	mut context := base.context()!
	mut redis := context.redis()!
	keys := redis.keys('git:repos:${gitstructure.key}:**')!

	// Delete all cached keys
	for key in keys {
		redis.del(key)!
	}
}

// Initialize the repository from a known path
fn (mut gitstructure GitStructure) repo_init_from_path_(path string) !GitRepo {
	// Find the parent directory containing .git
	mypath := pathlib.get_dir(path: path, create: false)!
	mut parent_path := mypath.parent_find('.git') or {
		return error('cannot find .git in parent starting from: ${path}')
	}

	if parent_path.path == '' {
		return error('cannot find .git in parent starting from: ${path}')
	}

	// Get GitLocation from the path
	gl := gitstructure.gitlocation_from_path(mypath.path)!

	// Initialize GitRepo struct
	return GitRepo{
		gs:            &gitstructure
		status_remote: GitRepoStatusRemote{}
		status_local:  GitRepoStatusLocal{}
		config:        GitRepoConfig{}
		provider:      gl.provider
		account:       gl.account
		name:          gl.name
	}
}
