module gittools

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.sshagent
import os

// LastCommitArgs holds the parameters for fetching the last commit.
@[params]
pub struct LastCommitArgs {
pub mut:
	fetch bool = true // If true, fetch the latest changes from the remote repository.
}

// Retrieves the last commit hash from the remote repository.
//
// If the `fetch` flag is true, the function first fetches the latest changes before getting the commit hash.
// If the current branch is the base branch (e.g., 'main' or 'master'), it prepends 'origin/' to the branch name.
//
// Returns:
// - The last commit hash as a string.
// - Throws an error if the command execution fails.
pub fn (mut repo GitRepo) get_last_remote_commit(args_ LastCommitArgs) !string {
	repo.check()!
	repo_path := repo.get_path()!
	mut branch_name := repo.status_local.branch
	is_base_branch := branch_name == repo.get_base_branch()!

	// If the branch is not an origin branch, adjust it for fetching.
	if args_.fetch && !branch_name.contains('origin/') && is_base_branch {
		branch_name = 'origin/${branch_name}'
	}

	// Fetch and get the last commit hash for the branch.
	cmd := 'git -C ${repo_path} fetch && git -C ${repo_path} rev-parse ${branch_name}'
	last_commit := osal.execute_silent(cmd)!
	commit_hash := string(last_commit).trim_space()
	repo.status_remote.latest_commit = commit_hash
	return last_commit
}

// Returns the latest commit hash from the local repository.
//
// Returns:
// - The latest local commit hash as a string.
// - Throws an error if the repository status check fails.
pub fn (mut repo GitRepo) get_last_local_commit() !string {
	repo.check()!
	repo_path := repo.get_path()!
	mut commit_hash := osal.execute_silent('git -C ${repo_path} rev-parse HEAD') or {
		return error('Failed to fetch commit hash: ${err}')
	}
	commit_hash = commit_hash.trim_space()
	repo.status_local.ref = commit_hash
	repo.status_local.latest_commit = commit_hash
	return commit_hash
}

// Retrieves a list of unstaged changes in the repository.
//
// This function returns a list of files that are modified or untracked but not staged for commit.
// It excludes ignored files from the list.
//
// Returns:
// - An array of strings representing file paths of unstaged changes.
// - Throws an error if the command execution fails.
pub fn (repo GitRepo) get_unstaged_changes() ![]string {
	repo.check()!
	repo_path := repo.get_path()!

	unstaged_result := osal.execute_silent('git -C ${repo_path} ls-files --other --modified --exclude-standard') or {
		return error('Failed to check for unstaged changes: ${err}')
	}

	// Filter out any empty lines from the result.
	return unstaged_result.split('\n').filter(it.len > 0)
}

// Retrieves a list of staged changes in the repository.
//
// This function returns a list of files that are staged and ready to be committed.
//
// Returns:
// - An array of strings representing file paths of staged changes.
// - Throws an error if the command execution fails.
pub fn (repo GitRepo) get_staged_changes() ![]string {
	repo.check()!
	repo_path := repo.get_path()!

	staged_result := osal.execute_silent('git -C ${repo_path} diff --name-only --staged') or {
		return error('Failed to check for staged changes: ${err}')
	}

	// Filter out any empty lines from the result.
	return staged_result.split('\n').filter(it.len > 0)
}

// Retrieves the base branch name of the repository.
//
// The base branch is typically the default branch (e.g., 'main' or 'master').
// The function extracts the base branch from the repository's remote settings.
//
// Returns:
// - The base branch name as a string.
// - Throws an error if the command execution fails.
pub fn (mut repo GitRepo) get_base_branch() !string {
	repo.check()!
	repo_path := repo.get_path()!

	// Command to get the base branch from the remote information.
	cmd := "git -C ${repo_path} remote show origin | grep 'HEAD branch'"
	mut branch_name := osal.execute_silent(cmd) or {
		return error('Failed to get the base branch due to: ${err}')
	}

	// Clean up the command output to extract the branch name.
	branch_name = string(branch_name).replace('HEAD branch:', '').trim_space()
	return branch_name
}

fn (repo GitRepo) get_key() string {
	return '${repo.gs.key}:${repo.provider}:${repo.account}:${repo.name}'
}

fn (repo GitRepo) get_cache_key() string {
	return 'git:repos:${repo.gs.key}:${repo.provider}:${repo.account}:${repo.name}'
}

pub fn (repo GitRepo) get_path() !string {
	return '${repo.gs.coderoot.path}/${repo.provider}/${repo.account}/${repo.name}'
}

// Relative path inside the gitstructure, pointing to the repo
pub fn (repo GitRepo) get_relative_path() !string {
	mut mypath := repo.patho()!
	return mypath.path_relative(repo.gs.coderoot.path) or { panic("couldn't get relative path") }
}

pub fn (repo GitRepo) get_parent_dir() !string {
	repo_path := repo.get_path()!
	parent_dir := os.dir(repo_path)
	if !os.exists(parent_dir) {
		return error('Parent directory does not exist: ${parent_dir}')
	}
	return parent_dir
}

// url_get returns the URL of a git address
fn (self GitRepo) get_repo_url() !string {
	if self.status_remote.url.len != 0 {
		return self.status_remote.url
	}
	
	if sshagent.loaded() {
		return self.get_ssh_url()!
	} else {
		return self.get_http_url()!
	}
}

fn (self GitRepo) get_ssh_url() !string {
	self.check()!
	mut provider := self.provider
	if provider == 'github' {
		provider = 'github.com'
	}
	return 'git@${provider}:${self.account}/${self.name}.git'
}

fn (self GitRepo) get_http_url() !string {
	self.check()!
	mut provider := self.provider
	if provider == 'github' {
		provider = 'github.com'
	}
	return 'https://${provider}/${self.account}/${self.name}'
}