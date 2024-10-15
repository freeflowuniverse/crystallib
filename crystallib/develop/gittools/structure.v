module gittools

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.base
import os

// GitStructure holds information about repositories within a specific code root.
// This structure keeps track of loaded repositories, their configurations, and their status.
@[heap]
pub struct GitStructure {
pub mut:
	key      string                // Unique key representing the git structure (default is hash of $home/code).
	config   GitStructureConfig    // Configuration settings for the git structure.
	coderoot pathlib.Path          // Root directory where repositories are located.
	repos    map[string]&GitRepo   // Map of repositories, keyed by their unique names.
	loaded   bool                  // Indicates if the repositories have been loaded into memory.
}

// ReposGetArgs defines arguments to retrieve repositories from the git structure.
// It includes filters by name, account, provider, and an option to clone a missing repo.
@[params]
pub struct ReposGetArgs {
pub mut:
	filter   string // Optional filter for repository names.
	name     string // Specific repository name to retrieve.
	account  string // Git account associated with the repository.
	provider string // Git provider (e.g., GitHub).
	clone    bool   // Clone the repository if it doesn't exist locally.
	pull     bool   // Pull the last changes.
	reset    bool   // Reset the changes.
	reload   bool   // Reload the repo.
	url      string // Repository URL, used if cloning is needed.
}

// Retrieves a list of repositories from the git structure that match the provided arguments.
// 
// Args:
// - args_ (ReposGetArgs): Struct containing filter criteria (name, account, provider, etc.).
//
// Returns:
// - []&GitRepo: A list of repository references that match the criteria.
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

// Retrieves a single repository based on the provided arguments.
// If the repository does not exist, and clone is requested, it will clone the repo.
//
// Args:
// - args_ (ReposGetArgs): Struct containing the repository name and clone options.
//
// Returns:
// - &GitRepo: Reference to the retrieved or cloned repository.
//
// Raises:
// - Error: If multiple repositories are found with similar names or if cloning fails.
pub fn (mut gitstructure GitStructure) get_repo(args_ ReposGetArgs) !&GitRepo {
	mut args := args_
	if args.name.len == 0 {
		return error('The repository name must be provided.')
	}

	repositories := gitstructure.get_repos(args)!

	if repositories.len == 0 {
		if args.clone && args.url.len == 0 {
			return error('Cannot clone the repository, no URL provided: ${args.url}')
		}

		if args.clone {
			return gitstructure.clone(args)!
		}
		return error('Cannot find repository with the given criteria.\n${args}')
	}

	if repositories.len > 1 {
		repos := repositories.map('- ${it.account}.${it.name}').join_lines()
		return error('Found more than one repository for \n${args}\n${repos}')
	}

	mut repo := repositories[0]

	if args_.pull{
		repo.pull()!
	}

	if args_.reset{
		// TODO: Implement this logic
		// repo.reset()!
	}

	if args_.reload{
		repo.load()!
	}

	return repositories[0]
}

// Clones a new repository into the git structure based on the provided arguments.
//
// Args:
// - args (ReposGetArgs): Struct containing clone options and repository URL.
//
// Returns:
// - &GitRepo: Reference to the cloned repository.
//
// Raises:
// - Error: If the cloning operation fails.
pub fn (mut gitstructure GitStructure) clone(args ReposGetArgs) !&GitRepo {
	console.print_header("The repository '${args.name}' does not exist, cloning from the URL: ${args.url}.")
	git_location := gitstructure.gitlocation_from_url(args.url)!
	mut repo := &GitRepo{
		provider: git_location.provider
		name: git_location.name
		account: git_location.account
		gs: gitstructure
		status_remote: GitRepoStatusRemote{
			url: args.url
		}
	}

	// Set the parent directory where the repository should be cloned.
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

// Loads all repository information from the filesystem and updates from remote if necessary.
// Use the reload argument to force reloading from the disk.
//
// Args:
// - args (StatusUpdateArgs): Arguments controlling the reload behavior.
pub fn (mut gitstructure GitStructure) load(args StatusUpdateArgs) ! {
	mut processed_paths := []string{}
	gitstructure.load_recursive(gitstructure.coderoot.path, args, mut processed_paths)!
}

// Recursively loads repositories from the provided path, updating their statuses.
//
// Args:
// - path (string): The path to search for repositories.
// - args (StatusUpdateArgs): Controls the status update and reload behavior.
// - processed_paths ([]string): List of already processed paths to avoid duplication.
fn (mut gitstructure GitStructure) load_recursive(path string, args StatusUpdateArgs, mut processed_paths []string) ! {
	console.print_debug('Recursively loading gitstructure from: ${path}')

	path_object := pathlib.get(path)
	relpath := path_object.path_relative(gitstructure.coderoot.path)!

	// Limit the recursion depth to avoid deep directory traversal.
	if relpath.count('/') > 4 {
		return
	}

	items := os.ls(path) or { return error('Cannot load gitstructure because directory not found: ${path}') }

	for item in items {
		current_path := os.join_path(path, item)

		if os.is_dir(current_path) {
			if os.exists(os.join_path(current_path, '.git')) {
				// Initialize the repository from the current path.
				mut repo := gitstructure.repo_init_from_path_(current_path)!
				repo.status_update(reload: args.reload)!

				key_ := repo.get_key()
				path_ := repo.get_path()!

				if processed_paths.contains(key_) || processed_paths.contains(path_) {
					return error('Duplicate repository detected.\nPath: ${path_}\nKey: ${key_}')
				}

				processed_paths << path_
				processed_paths << key_
				gitstructure.repos[key_] = &repo
				continue
			}
			if item.starts_with('.') || item.starts_with('_') {
				continue
			}
			// Recursively search in subdirectories.
			gitstructure.load_recursive(current_path, args, mut processed_paths)!
		}
	}
}

// Resets the cache for the current Git structure, removing cached data from Redis.
pub fn (mut gitstructure GitStructure) cachereset() ! {
	mut context := base.context()!
	mut redis := context.redis()!
	keys := redis.keys('git:repos:${gitstructure.key}:**')!

	for key in keys {
		redis.del(key)!
	}
}

// Initializes a Git repository from a given path by locating the parent directory with `.git`.
//
// Args:
// - path (string): Path to initialize the repository from.
//
// Returns:
// - GitRepo: Reference to the initialized repository.
//
// Raises:
// - Error: If `.git` is not found in the parent directories.
fn (mut gitstructure GitStructure) repo_init_from_path_(path string) !GitRepo {
	mypath := pathlib.get_dir(path: path, create: false)!
	mut parent_path := mypath.parent_find('.git') or {
		return error('Cannot find .git in parent directories starting from: ${path}')
	}

	if parent_path.path == '' {
		return error('Cannot find .git in parent directories starting from: ${path}')
	}

	// Retrieve GitLocation from the path.
	gl := gitstructure.gitlocation_from_path(mypath.path)!

	// Initialize and return a GitRepo struct.
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

// Helper function to check if a repository matches the criteria (name, account, provider).
//
// Args:
// - repo (GitRepo): The repository to check.
// - args (ReposGetArgs): The criteria to match against.
//
// Returns:
// - bool: True if the repository matches, false otherwise.
fn is_repo_matches(repo GitRepo, args ReposGetArgs) bool {
	return (args.name.len == 0 || repo.name == args.name) &&
	(args.account.len == 0 || repo.account == args.account) &&
	(args.provider.len == 0 || repo.provider == args.provider)
}
