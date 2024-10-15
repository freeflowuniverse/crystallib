module gittools

// GitStructureConfig defines configuration settings for a GitStructure instance.
@[params]
pub struct GitStructureConfig {
pub mut:
	coderoot string // Root directory where code is checked out, comes from context if not specified
	light    bool = true // If true, clones only the last history for all branches
	log      bool // If true, logs git commands/statements
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

// GitStructureGetArgs holds parameters for retrieving a GitStructure instance.
@[params]
pub struct GitStructureGetArgs {
pub mut:
	coderoot string // Root directory for the code
	reload   bool   // If true, reloads the GitStructure from disk
}

@[params]
pub struct StatusUpdateArgs {
	reload bool
}