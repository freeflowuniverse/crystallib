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

// Arguments used when performing repository operations like branch management or commits.
@[params]
pub struct RepositoryArgs {
pub mut:
	branch_name             string // The branch to act on.
	tag_name                string // The tag to act on.
	checkout                bool   // Whether to checkout the branch.
	pull                    bool   // Whether to pull after checkout.
	checkout_to_base_branch bool   // Whether to checkout to the base branch (e.g., main).
}

// ActionArgs defines parameters for performing Git actions like commit, push, or pull.
@[params]
pub struct ActionArgs {
pub mut:
	reload    bool   = true // Whether to reload the repository status.
	msg       string        // The commit message.
	branch    string        // The branch to act on.
	tag       string        // The tag to checkout.
	recursive bool          // Perform recursive actions (e.g., update submodules).
	push_tag  bool          // Determine whether the user needs to push the tags or not.
}

// Check if there are any unstaged or untracked changes in the repository.
pub fn (repo GitRepo) has_changes() !bool {
	repo.check()!
	untracked_changes := repo.get_unstaged_changes()!
	return untracked_changes.len > 0
}

// Stage all changes in the repository.
pub fn (mut repo GitRepo) add_changes() ! {
	repo.check()!
	repo_path := repo.get_path()!
	cmd := 'git -C ${repo_path} add . -A'
	osal.exec(cmd: cmd) or { return error('Cannot add to repo: ${repo_path}. Error: ${err}') }
	console.print_green('Changes added successfully.')
}

// Check if there are staged changes to commit.
pub fn (repo GitRepo) need_commit() !bool {
	repo.check()!
	return repo.get_staged_changes()!.len > 0
}

// Commit the staged changes with the provided commit message.
pub fn (mut repo GitRepo) commit(args_ ActionArgs) ! {
	mut args := repo.reload_if_needed(args_)!
	if repo.need_commit()! {
		if args.msg == '' {
			return error('Commit message is empty.')
		}
		repo_path := repo.get_path()!
		cmd := 'git -C ${repo_path} commit -m "${args.msg}"'
		osal.exec(cmd: cmd) or { return error('Cannot commit repo: ${repo_path}. Error: ${err}') }
		console.print_green('Changes committed successfully.')
	} else {
		console.print_stderr('No changes to commit.')
	}
	repo.load()!
}

// Check if the repository has changes that need to be pushed.
pub fn (mut repo GitRepo) need_push() !bool {
	repo.check()!
	last_remote_commit := repo.get_last_remote_commit() or { return error('Failed to get last remote commit: ${err}') }
	last_local_commit := repo.get_last_local_commit() or { return error('Failed to get last local commit: ${err}') }
	return last_local_commit != last_remote_commit
}

// Push local changes to the remote repository.
pub fn (mut repo GitRepo) push(args_ ActionArgs) ! {
	if repo.need_push()! {
		repo.reload_if_needed(args_)!
		repo_path := repo.get_path()!
		url := repo.get_repo_url()!
		console.print_header('Pushing changes to ${url}')

		base_branch := repo.get_base_branch()!
		mut cmd := ''

		if args_.branch == base_branch {
			'git -C ${repo_path} push'
		} else {
			'git -C ${repo_path} push origin HEAD'
		}

		if args_.push_tag{
			cmd = 'git -C ${repo_path} push --tags'
		}

		osal.exec(cmd: cmd) or { return error('Failed to push due to: ${err}') }
		console.print_green('Changes pushed successfully.')
		repo.load()!
	} else {
		console.print_header('Everything is up to date.')
		repo.load()!
	}
}

// Check if a pull is needed (if remote has new changes).
pub fn (mut repo GitRepo) need_pull() !bool {
	repo.get_last_remote_commit(fetch: true)!
	return repo.status_remote.latest_commit != repo.status_local.latest_commit
}

// Pull remote content into the repository.
pub fn (mut repo GitRepo) pull(args_ ActionArgs) ! {
	branch_args := RepositoryArgs{
		branch_name: args_.branch
		tag_name: args_.tag
	}

	if repo.need_checkout(branch_args)! {
		repo.checkout(branch_args)!
	}

	repo_path := repo.get_path()!
	cmd := 'git -C ${repo_path} pull'
	osal.exec(cmd: cmd) or { return error('Cannot pull repo: ${repo_path}. Error: ${err}') }


	if args_.recursive {
		repo.update_submodules()!
	}

	repo.load()!
	console.print_green('Changes pulled successfully.')
}

// Determine if the repository needs to checkout to a different branch.
fn (mut repo GitRepo) need_checkout(args_ RepositoryArgs) !bool {
	return args_.branch_name != repo.status_local.branch || args_.tag_name != repo.status_local.tag
}

// Checkout a branch in the repository.
pub fn (mut repo GitRepo) checkout(args_ RepositoryArgs) ! {
	mut args := args_
	if args.branch_name.len > 0 && args.tag_name.len > 0 {
		return error('You can only specify either the branch name nor tag name.')
	}

	repo.load()!
	repo_path := repo.get_path()!

	if repo.need_commit()! {
		return error('Cannot checkout branch due to uncommitted changes in ${repo_path}.')
	}

	repo.fetch_all()!

	if args.checkout_to_base_branch {
		repo.status_local.branch = repo.get_base_branch()!
	}
	
	if args.branch_name.len > 0 {
		repo.status_local.branch = args.branch_name
	}

	if args.tag_name.len > 0 {
		repo.status_local.tag = args.tag_name
	}

	checkout_to := if args.tag_name.len > 0 {repo.status_local.tag} else {repo.status_local.branch}

	cmd := 'git -C ${repo_path} checkout ${checkout_to}'
	osal.exec(cmd: cmd) or { return error('Cannot checkout branch: ${repo_path}. Error: ${err}') }
	console.print_green('Switched to branch ${repo.status_local.branch} successfully.')

	if args.pull {
		repo.pull(reload: true)!
	}
}

// Create a new branch in the repository.
pub fn (mut repo GitRepo) create_branch(args_ RepositoryArgs) ! {
	repo_path := repo.get_path()!
	cmd := if args_.checkout { 'checkout -b' } else { 'branch -c' }
	full_cmd := 'git -C ${repo_path} ${cmd} ${args_.branch_name}'
	osal.exec(cmd: full_cmd) or { return error('Cannot create branch: ${repo_path}. Error: ${err}') }
	console.print_green('Branch ${args_.branch_name} created successfully.')

	if args_.checkout{
		repo.status_local.branch = args_.branch_name
		repo.status_local.tag = ''
	}
}

// Create a new branch in the repository.
pub fn (mut repo GitRepo) create_tag(args_ RepositoryArgs) ! {
	repo_path := repo.get_path()!
	mut cmd := 'git -C ${repo_path} tag ${args_.tag_name}'

	osal.exec(cmd: cmd) or { return error('Cannot create tag: ${repo_path}. Error: ${err}') }
	console.print_green('Tag ${args_.tag_name} created successfully.')

	if args_.checkout{
		cmd = 'git -C ${repo_path} checkout ${args_.tag_name}'
		osal.exec(cmd: cmd) or { return error('Cannot checkout to tag: ${args_.tag_name}. Error: ${err}') }
		console.print_green('Tag ${args_.branch_name} activated.')
		repo.status_local.branch = ''
		repo.status_local.tag = args_.tag_name
	}
}

// Create a new branch in the repository.
pub fn (mut repo GitRepo) is_tag_exists(args_ RepositoryArgs) !bool {
	repo.fetch_all()!
	repo.load()!
	repo_path := repo.get_path()!
	mut cmd := 'git -C ${repo_path} show ${args_.tag_name}'

	osal.exec(cmd: cmd) or { return false }
	return true
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

	repo.load_local_branch_info(path)!
	repo.load_remote_info(path)!

	repo.status_local.last_check = int(time.now().unix())
	repo.status_remote.last_check = int(time.now().unix())
}

// Helper to load local branch or tag info
fn (mut repo GitRepo) load_local_branch_info(path string) ! {
	repo.get_last_local_commit()!
	cmd_result := osal.execute_silent('git -C ${path} rev-parse --abbrev-ref HEAD') or {
		return error('Failed to fetch branch info: ${err}')
	}

	branch_or_head := cmd_result.trim_space()
	if branch_or_head == 'HEAD' {
		repo.status_local.detached = true
		repo.status_local.tag = osal.execute_silent('git -C ${path} describe --tags --exact-match') or { '' }.trim_space()
	} else {
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

	repo.get_last_remote_commit(fetch: true)!
	repo.load_remote_branches(path)!
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

// Create GitLocation from the path within the Git repository
pub fn (mut gs GitRepo) gitlocation_from_path(path string) !GitLocation {
	if path.starts_with('/') || path.starts_with('~') {
		return error('Path must be relative, cannot start with / or ~')
	}

	mut git_path := gs.patho()!
	if !os.exists(git_path.path) {
		return error('Path does not exist inside the repository: ${git_path.path}')
	}

	return GitLocation{
		provider: gs.provider
		account:  gs.account
		name:     gs.name
		branch:   gs.status_local.branch
		tag:      gs.status_local.tag
		path:     path
	}
}

// Check if repo path exists and validate fields
pub fn (repo GitRepo) check() ! {
	path_string := repo.get_path()!
	if repo.gs.coderoot.path == '' {
		return error('Coderoot cannot be empty')
	}
	if repo.provider == '' {
		return error('Provider cannot be empty')
	}
	if repo.account == '' {
		return error('Account cannot be empty')
	}
	if repo.name == '' {
		return error('Name cannot be empty')
	}

	if !os.exists(path_string) {
		return error('Path does not exist: ${path_string}')
	}
}

pub fn (mut repo GitRepo) status_update(args StatusUpdateArgs) ! {
	// Check current time vs last check, if needed (check period) then load
	repo.redis_load()! // Ensure we have the situation from redis
	current_time := int(time.now().unix())
	if args.reload || repo.config.remote_check_period == 0
		|| current_time - repo.status_remote.last_check >= repo.config.remote_check_period {
		repo.load()!
	}
}

pub fn (mut repo GitRepo) fetch_all() ! {
	cmd := 'cd ${repo.get_path()!} && git fetch --all'
	osal.execute_silent(cmd) or {
		return error('Cannot fetch repo: ${repo.get_path()!}. Error: ${err}')
	}
	repo.load()!
}

// Removes all changes from the repo; be cautious
pub fn (mut repo GitRepo) remove_changes(args_ ActionArgs) ! {
	repo.reload_if_needed(args_)!
	if repo.need_commit()! {
		console.print_header('Removing changes in ${repo.get_path()!}')
		cmd := 'cd ${repo.get_path()!} && git reset HEAD --hard && git clean -xfd'
		res := osal.exec(cmd: cmd, raise_error: false)!
		if res.exit_code > 0 {
			console.print_header('Could not remove changes; will re-clone ${repo.get_path()!}')
			mut p := repo.patho()!
			p.delete()! // remove path, this will re-clone the full thing
			// Uncomment to re-clone the repo
			// repo.load_from_url()!
		}
	}
	repo.load()!
}



// Helper method to reload the repo if needed
fn (mut repo GitRepo) reload_if_needed(args_ ActionArgs) !ActionArgs {
	mut args := args_
	if args.reload {
		repo.load()!
		args.reload = false
	}
	return args
}


// Update submodules
fn (mut repo GitRepo) update_submodules() ! {
	cmd := 'cd ${repo.get_path()!} && git submodule update --init --recursive'
	osal.execute_silent(cmd) or {
		return error('Cannot update submodules for repo: ${repo.get_path()!}. Error: ${err}')
	}
}
