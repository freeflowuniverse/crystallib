module gittools

import freeflowuniverse.crystallib.core.pathlib

// GitStructure holds information about repositories in a memory structure.
@[heap]
pub struct GitStructure {
pub mut:
	key      string              // Unique key for the git structure (hash of the path or default is $home/code)
	config   GitStructureConfig  // Configuration settings
	coderoot pathlib.Path        // Root directory for the code
	repos    map[string]&GitRepo // Map of repositories in the git structure
	loaded   bool                // Indicates if directories have been walked and cached in redis
}

// GitStructureConfig defines configuration settings for a GitStructure instance.
@[params]
pub struct GitStructureConfig {
pub mut:
	coderoot string // Root directory where code is checked out, comes from context if not specified
	light    bool = true // If true, clones only the last history for all branches
	log      bool // If true, logs git commands/statements
}

// GitRepo holds information about a single Git repository.
pub struct GitRepo {
pub mut:
	gs            &GitStructure @[skip] // Reference to the parent GitStructure
	provider      string              // e.g., github.com, shortened to 'github'
	account       string              // Git account name
	name          string              // Repository name
	status_remote GitRepoStatusRemote // Remote repository status
	status_local  GitRepoStatusLocal  // Local repository status
	config        GitRepoConfig       // Repository-specific configuration
}

// GitRepoStatusRemote holds remote status information for a repository.
pub struct GitRepoStatusRemote {
pub mut:
	url           string            // Remote repository URL
	latest_commit string            // Latest commit hash
	branches      map[string]string // Branch name -> commit hash
	tags          map[string]string // Tag name -> commit hash
	last_check    int               // Epoch timestamp of the last check
}

// GitRepoStatusLocal holds local status information for a repository.
pub struct GitRepoStatusLocal {
pub mut:
	url        string // Local repository URL
	detached   bool   // True if not on a branch (e.g., on a tag)
	branch     string // Current branch
	tag        string // If the local branch is not set, the tag may be set
	ref        string // Commit reference hash
	last_check int    // Epoch timestamp of the last check
	latest_commit string            // Latest commit hash
}

// GitRepoConfig holds repository-specific configuration options.
pub struct GitRepoConfig {
pub mut:
	remote_check_period int // Seconds to wait between remote checks (0 = check every time)
}

// CodeGetFromUrlArgs holds the parameters for retrieving code from a URL into a GitStructure.
@[params]
pub struct CodeGetFromUrlArgs {
	GSCodeGetFromUrlArgs
pub mut:
	coderoot          string
	gitstructure_name string = 'default'
}

// GSCodeGetFromUrlArgs defines the parameters for retrieving code from a URL.
pub struct GSCodeGetFromUrlArgs {
pub mut:
	path   string // Local path
	url    string // Remote repository URL
	branch string // Branch name
	tag    string // Tag name
	sshkey string // SSH key for access
	pull   bool   // If true, pulls changes from the remote repository
	reset  bool   // If true, resets changes before pulling
	reload bool   // If true, reloads the cache
}

// GitLocation uniquely identifies a Git repository, its online URL, and its location in the filesystem.
@[heap]
pub struct GitLocation {
pub mut:
	provider string // Git provider (e.g., GitHub)
	account  string // Account name
	name     string // Repository name
	branch   string // Branch name
	tag      string // Tag name
	path     string // Path in the repository (not the filesystem)
	anker    string // Position in a file
}

// ReposActionsArgs defines the arguments for performing actions on repositories.
@[params]
pub struct ReposActionsArgs {
pub mut:
	cmd       string // Command to execute (clone, commit, pull, push, etc.)
	filter    string // Filter for repository names
	repo      string // Specific repository name
	account   string // Git account name
	provider  string // Git provider (e.g., GitHub)
	msg       string // Commit message
	url       string // Remote repository URL
	branch    string // Branch name
	tag       string // Tag name
	recursive bool   // If true, performs action recursively
	pull      bool   // If true, pulls changes from the remote repository
	script    bool = true // Non-interactive mode
	reset     bool = true // If true, discards local changes before pulling
}

// CloneArgs holds the parameters for cloning a repository.
@[params]
pub struct CloneArgs {
pub mut:
	forcehttp bool   // If true, forces use of HTTP instead of SSH
	branch    string // Branch name to clone
}

// ReposGetArgs defines the parameters for retrieving repositories based on criteria.
@[params]
pub struct ReposGetArgs {
pub mut:
	filter   string // Filter for repository names
	name     string // Specific repository name
	account  string // Git account name
	provider string // Git provider (e.g., GitHub)
}

// GitStructureGetArgs holds parameters for retrieving a GitStructure instance.
@[params]
pub struct GitStructureGetArgs {
pub mut:
	coderoot string // Root directory for the code
	reload   bool   // If true, reloads the GitStructure from disk
}

@[params]
pub struct ActionArgs {
pub mut:
	reload    bool = true
	msg       string // only relevant for commit
	branch    string
	tag       string
	recursive bool
}

@[params]
pub struct StatusUpdateArgs {
	reload bool
}
