module gittools

import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.osal
import os
import time

// GitRepo holds information about a single Git repository.
pub struct GitRepo {
pub mut:
	gs            &GitStructure @[skip;str: skip] // Reference to the parent GitStructure
	provider      string              // e.g., github.com, shortened to 'github'
	account       string              // Git account name
	name          string              // Repository name
	status_remote GitRepoStatusRemote // Remote repository status
	status_local  GitRepoStatusLocal  // Local repository status
	config        GitRepoConfig       // Repository-specific configuration
}

// Arguments used when performing actions on a repository, such as branch operations or commits.
@[params]
pub struct RepositoryArgs {
pub mut:
	branch_name             string // The name of the branch to act on
	checkout                bool   // Whether to checkout to the branch
	pull                    bool   // Whether to pull after checking out
	checkout_to_base_branch  bool   // Whether to checkout to the base branch (e.g., main)
}

// Arguments used for various actions like push, pull, or commit.
@[params]
pub struct ActionArgs {
pub mut:
	reload    bool   = true // Whether to reload the repository status
	msg       string        // The commit message
	branch    string        // The branch name
	tag       string        // The tag to checkout
	recursive bool          // Whether to perform recursive operations (e.g., updating submodules)
}

// Checks if there are any unstaged or untracked changes in the repository.
// Returns true if changes are present, false otherwise.
pub fn (repo GitRepo) has_changes() !bool {
	repo.check()!
	untracked_result := repo.get_unstaged_changes()!
	return untracked_result.len > 0
}

// Stages all changes in the repository.
// Executes the Git command to add all changes and returns an error if the command fails.
pub fn (mut repo GitRepo) add_changes() ! {
	repo.check()!
	repo_path := repo.get_path()!
	cmd := 'cd ${repo_path} && git add . -A'
	osal.exec(cmd: cmd) or { return error('Cannot add to repo: ${repo_path}. Error: ${err}') }
	console.print_green('Changes added successfully.')
}

// Checks if there are staged changes that need to be committed.
// Returns true if there are staged changes, false otherwise.
pub fn (repo GitRepo) need_commit() !bool {
	repo.check()!
	return repo.get_staged_changes()!.len > 0
}

// Commits the staged changes in the repository with a specified commit message.
// Returns an error if the commit message is empty or if the command fails.
pub fn (mut repo GitRepo) commit(args_ ActionArgs) ! {
	mut args := repo.reload_if_needed(args_)!
	if repo.need_commit()! {
		if args.msg == '' {
			return error('Cannot commit; message is empty for ${repo}')
		}
		repo_path := repo.get_path()!
		cmd := 'cd ${repo_path} && git commit -m "${args.msg}"'
		osal.exec(cmd: cmd) or { return error('Cannot commit repo: ${repo_path}. Error: ${err}') }
		console.print_green('Changes committed successfully.')
	} else {
		console.print_stderr('No changes to commit.')
	}
	repo.load()!
}

// Determines if the repository needs to push changes based on local and remote commits.
// Returns true if there are local changes that need to be pushed, false otherwise.
pub fn (mut repo GitRepo) need_push() !bool {
	repo.check()!
	last_remote_commit := repo.get_last_remote_commit() or {
		return error('Cannot get the last remote commit due to: ${err}')
	}
	last_local_commit := repo.get_last_local_commit() or {
		return error('Cannot get the last local commit due to: ${err}')
	}
	return last_local_commit != last_remote_commit
}

// Pushes local changes to the remote repository.
// Executes the Git command to push changes and returns an error if the command fails.
pub fn (mut repo GitRepo) push(args_ ActionArgs) ! {
	if repo.need_push()! {
		repo.reload_if_needed(args_)!
		repo_path := repo.get_path()!
		url := repo.get_repo_url()!
		console.print_header('Pushing changes to ${url}')

		is_base_branch := args_.branch == repo.get_base_branch()!
		mut cmd := ''

		// If the current branch is the base branch (like 'main' or 'master')
		if is_base_branch {
			cmd = 'git -C ${repo_path} push'
		} else {
			// Push the current local branch to the remote branch of the same name
			// Using 'git push origin HEAD' ensures the current branch is pushed
			cmd = 'git -C ${repo_path} push origin HEAD'
		}

		osal.exec(cmd: cmd) or { return error('Cannot push repo: ${repo_path}. Error: ${err}') }
		console.print_green('Changes pushed successfully.')
		repo.load()!
	} else {
		console.print_header('Everything is up to date.')
		repo.load()!
	}
}

// Checks if the repository needs to pull updates from the remote.
// Returns true if the remote has new changes compared to the local repository.
pub fn (mut repo GitRepo) need_pull() !bool {
	repo.get_last_remote_commit(fetch: true)!
	return repo.status_remote.latest_commit != repo.status_local.latest_commit
}

// Pulls remote content, failing if there are local changes that are not committed.
// Executes the pull command and handles recursive submodule updates if needed.
pub fn (mut repo GitRepo) pull(args_ ActionArgs) ! {
	branch_args := RepositoryArgs{
		branch_name: args_.branch
	}

	if repo.need_checkout_branch(branch_args)! {
		repo.checkout_branch(branch_args)!
	}

	repo_path := repo.get_path()!
	cmd := 'git -C ${repo_path} pull'
	osal.exec(cmd: cmd) or { return error('Cannot pull repo: ${repo_path}. Error: ${err}') }

	if args_.tag != '' {
		repo.checkout_tag(args_.tag)!
	}

	if args_.recursive {
		repo.update_submodules()!
	}

	repo.load()!
	console.print_green('Changes pulled successfully.')
}

// Helper function to determine if a branch checkout is needed.
fn (mut repo GitRepo) need_checkout_branch(args_ RepositoryArgs) !bool {
	if args_.branch_name.len == 0 {
		return error('The branch name is required.')
	}
	return args_.branch_name != repo.status_local.branch
}

// Checks out the specified branch in the repository, optionally pulling the latest changes.
// Returns an error if the checkout fails or if there are uncommitted changes.
pub fn (mut repo GitRepo) checkout_branch(args_ RepositoryArgs) ! {
	mut args := args_
	if !args.checkout_to_base_branch && args.branch_name.len == 0 {
		return error('The branch name is required.')
	}

	repo.load()!
	repo_path := repo.get_path()!

	if repo.need_commit()! {
		return error('Cannot checkout branch in ${repo_path} due to uncommitted changes.')
	}

	repo.fetch_all()!

	if args.checkout_to_base_branch {
		// Get the base branch of the repo
		args.branch_name = repo.get_base_branch()!
	}

	cmd := 'git -C ${repo_path} checkout ${args.branch_name}'
	osal.exec(cmd: cmd) or { return error('Cannot checkout branch in ${repo_path}. Error: ${err}') }
	repo.status_local.branch = args.branch_name
	console.print_green('Switched to branch ${args.branch_name} successfully.')

	if args.pull {
		console.print_green('Pulling the branch ${args.branch_name} changes.')
		repo.pull(reload: true)!
	}
}

// Creates a new branch in the repository.
// Optionally checks out the branch after creation.
pub fn (mut repo GitRepo) create_branch(args_ RepositoryArgs) ! {
	repo_path := repo.get_path()!
	base_command := if args_.checkout { 'checkout -b' } else { 'branch -c' }
	cmd := 'git -C ${repo_path} ${base_command} ${args_.branch_name}'
	osal.exec(cmd: cmd) or { return error('Cannot create branch in ${repo_path}. Error: ${err}') }
	console.print_green('Branch ${args_.branch_name} created successfully.')
}

// Remove cache
fn (repo GitRepo) delete_cache() ! {
	mut context := base.context() or { return error('Cannot get the context due to: ${err}') }
	mut redis := context.redis() or { return error('Cannot get redis due to: ${err}') }
	cache_key := repo.get_cache_key()
	redis.del(cache_key) or { return error('Cannot delete the repo cache due to: ${err}') }
}

// Deletes the Git repository
pub fn (mut repo GitRepo) delete() ! {
	repo_path := repo.get_path()!
	if !os.exists(repo_path) {
		return error('The repo path ${repo_path} does not exists')
	}

	repo.delete_cache()!
	cmd := 'rm -rf ${repo_path}'
	osal.exec(cmd: cmd) or { return error('Cannot execute the delete command due to: ${err}') }
	repo.load()!
}

// Load repo information
fn (mut repo GitRepo) load() ! {
	console.print_debug('load ${repo.get_key()}')
	path := repo.get_path()!

	// Load local branch info
	repo.load_local_branch_info(path)!

	// Load remote repository info
	repo.load_remote_info(path)!

	// Fill in check timestamps for local and remote
	repo.status_local.last_check = int(time.now().unix())
	repo.status_remote.last_check = int(time.now().unix())
}

// Helper to load local branch or tag info
fn (mut repo GitRepo) load_local_branch_info(path string) ! {
	// Fetch commits hash and set it as the latest commit
	repo.get_last_local_commit()!

	// Fetch local branch or detached head
	cmd_result := osal.execute_silent('git -C ${path} rev-parse --abbrev-ref HEAD') or {
		return error('Failed to fetch branch info: ${err}')
	}

	branch_or_head := cmd_result.trim_space()
	if branch_or_head == 'HEAD' {
		// Detached head: fetch tag if any
		repo.status_local.detached = true
		repo.status_local.tag = osal.execute_silent('git -C ${path} describe --tags --exact-match') or { '' }.trim_space()
	} else {
		// Not detached: set branch name
		repo.status_local.detached = false
		repo.status_local.branch = branch_or_head
	}
}

// Helper to load remote branch and tag information
fn (mut repo GitRepo) load_remote_info(path string) ! {
	// Fetch repo URL
	repo.status_remote.url = osal.execute_silent('git -C ${path} config --get remote.origin.url') or {
		return error('Failed to fetch remote URL: ${err}')
	}

	// Load last remote commit
	repo.get_last_remote_commit(fetch: true)!

	// Fetch and process remote branches
	repo.load_remote_branches(path)!

	// Fetch and process remote tags
	repo.load_remote_tags(path)!
}

// Helper to load remote branches
fn (mut repo GitRepo) load_remote_branches(path string) ! {
	branches_result := osal.execute_silent('git -C ${path} branch -r --format "%(refname:lstrip=2) %(objectname)"') or {
		return error('Failed to fetch remote branches: ${err}')
	}

	for line in branches_result.split('\n') {
		if line.trim_space() != '' {
			parts := line.split(' ')
			if parts.len == 2 {
				branch_name := parts[0].trim_space().replace('origin/', '')
				commit_hash := parts[1].trim_space()

				// Update remote branches info
				repo.status_remote.branches[branch_name] = commit_hash

				// Set the latest remote commit if it matches the current branch
				if branch_name == repo.status_local.branch {
					repo.status_remote.latest_commit = commit_hash
				}
			}
		}
	}
}

// Helper to load remote tags
fn (mut repo GitRepo) load_remote_tags(path string) ! {
	tags_result := osal.execute_silent('git -C ${path} show-ref --tags') or { '' }

	for line in tags_result.split('\n') {
		if line.trim_space() != '' {
			parts := line.split(' ')
			if parts.len == 2 {
				commit_hash := parts[0].trim_space()
				tag_name := parts[1].all_after('refs/tags/').trim_space()

				// Update remote tags info
				repo.status_remote.tags[tag_name] = commit_hash
			}
		}
	}
}
