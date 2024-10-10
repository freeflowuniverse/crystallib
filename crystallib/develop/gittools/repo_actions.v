module gittools

import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.develop.vscode
import freeflowuniverse.crystallib.develop.sourcetree
import os

fn (repo GitRepo) get_clone_cmd(args CloneArgs) !string {
	url := if args.forcehttp { repo.url_http_get()! } else { repo.url_get()! }
	light := if repo.gs.config.light { ' --depth 1 --no-single-branch' } else { '' }
	path := repo.path_account()!

	mut cmd := 'cd ${path.path} && git clone ${light} ${url} ${repo.name}'
	if args.branch != '' {
		cmd += ' -b ${args.branch}'
	}
	return cmd
}

// Pulls remote content in and resets changes
pub fn (mut repo GitRepo) pull_reset(args_ ActionArgs) ! {
	mut args := repo.reload_if_needed(args_)!
	repo.remove_changes(args)!
	repo.pull(args)!
}

// Commits changes, pulls from remote, and pushes to remote
pub fn (mut repo GitRepo) commit_pull_push(args_ ActionArgs) ! {
	mut args := repo.reload_if_needed(args_)!
	repo.commit(args)!
	repo.pull(args)!
	repo.push(args)!
}

// Commits changes and pulls from remote
pub fn (mut repo GitRepo) commit_pull(args_ ActionArgs) ! {
	mut args := repo.reload_if_needed(args_)!
	repo.commit(args)!
	repo.pull(args)!
}

// Pulls remote content, failing if there are local changes
pub fn (mut repo GitRepo) pull(args_ ActionArgs) ! {
	repo.switch_branch_if_needed(args_)!

	cmd := 'cd ${repo.path()!} && git pull'
	osal.execute_silent(cmd) or {
		return error('Cannot pull repo: ${repo.path}. Error: ${err}')
	}

	if args_.tag != '' {
		repo.checkout_tag(args_.tag)!
	}

	if args_.recursive {
		repo.update_submodules()!
	}

	repo.load()!
}

// Helper function to switch branches if needed
fn (mut repo GitRepo) switch_branch_if_needed(args_ ActionArgs) ! {
	if args_.branch != '' && args_.branch != repo.status_local.branch {
		console.print_header('Switching branch from ${repo.status_local.branch} to ${args_.branch} for ${repo.status_local.url}')
		repo.branch_switch(args_.branch)!
	}
}

// Checkout specific tag
fn (mut repo GitRepo) checkout_tag(tag string) ! {
	cmd := 'cd ${repo.path()!} && git checkout ${tag}'
	osal.execute_silent(cmd) or {
		return error('Cannot checkout tag ${tag} for repo: ${repo.path()!}. Error: ${err}')
	}
}

// Update submodules
fn (mut repo GitRepo) update_submodules() ! {
	cmd := 'cd ${repo.path()!} && git submodule update --init --recursive'
	osal.execute_silent(cmd) or {
		return error('Cannot update submodules for repo: ${repo.path()!}. Error: ${err}')
	}
}

pub fn (repo GitRepo) get_unstaged_changes() ![]string {
	repo.check()!
	repo_path := repo.path()!

	unstaged_result := osal.execute_silent('git -C ${repo_path} ls-files --other --modified --exclude-standard') or {
		return error('Failed to check for unstaged changes: ${err}')
	}

	return unstaged_result.split('\n').filter(it.len > 0)
}

pub fn (repo GitRepo) get_staged_changes() ![]string {
	repo.check()!
	repo_path := repo.path()!

	staged_result := osal.execute_silent('git -C ${repo_path} diff --name-only --staged') or {
		return error('Failed to check for staged changes: ${err}')
	}

	return staged_result.split('\n').filter(it.len > 0)
}

pub fn (mut repo GitRepo) display_current_status() ! {
	staged_changes := repo.get_staged_changes()!
	unstaged_changes := repo.get_unstaged_changes()!

	console.print_header('Staged changes:')
	for f in staged_changes {
		console.print_green('\t- ${f}')
	}

	console.print_header('Unstaged changes:')
	if unstaged_changes.len == 0 {
		console.print_stderr('No unstaged changes; the changes need to be committed.')
		return
	}

	for f in unstaged_changes {
		console.print_stderr('\t- ${f}')
	}
}

pub fn (mut repo GitRepo) add_changes() ! {
	repo.check()!
	cmd := 'cd ${repo.path()!} && git add . -A'
	osal.execute_silent(cmd) or {
		return error('Failed to add changes: ${err}')
	}
	repo.display_current_status()!
}

pub fn (mut repo GitRepo) commit(args_ ActionArgs) ! {
	mut args := repo.reload_if_needed(args_)!
	if repo.need_commit()! {
		if args.msg == '' {
			return error('Cannot commit; message is empty for ${repo}')
		}
		repo_path := repo.path()!
		cmd := 'cd ${repo_path} && git commit -m "${args.msg}"'
		osal.execute_silent(cmd) or {
			return error('Cannot commit repo: ${repo_path}. Error: ${err}')
		}
		console.print_green('Changes committed successfully.')
	} else {
		console.print_stderr('No changes to commit.')
	}
	repo.load()!
}

// Removes all changes from the repo; be cautious
pub fn (mut repo GitRepo) remove_changes(args_ ActionArgs) ! {
	repo.reload_if_needed(args_)!
	if repo.need_commit()! {
		console.print_header('Removing changes in ${repo.path()!}')
		cmd := 'cd ${repo.path()!} && git reset HEAD --hard && git clean -xfd'
		res := osal.exec(cmd: cmd, raise_error: false)!
		if res.exit_code > 0 {
			console.print_header('Could not remove changes; will re-clone ${repo.path()!}')
			mut p := repo.patho()!
			p.delete()! // remove path, this will re-clone the full thing
			// Uncomment to re-clone the repo
			// repo.load_from_url()!
		}
	}
	repo.load()!
}

pub fn (mut repo GitRepo) push(args_ ActionArgs) ! {
	repo.reload_if_needed(args_)!
	if repo.need_push()! {
		url := repo.url_get()!
		console.print_debug('Pushing changes to ${url}')
		cmd := 'cd ${repo.path()!} && git push'
		osal.execute_silent(cmd) or {
			return error('Cannot push repo: ${repo.path()!}. Error: ${err}')
		}
	}
	repo.load()!
}

pub fn (mut repo GitRepo) branch_switch(branchname string) ! {
	repo.load()!
	if repo.need_commit()! || repo.need_push()! {
		return error('Cannot switch branches in ${repo.path()!} due to uncommitted changes.')
	}
	repo.fetch_all()!
	cmd := 'cd ${repo.path()!} && git checkout ${branchname}'
	osal.execute_silent(cmd) or {
		return error('Cannot switch branch in ${repo.path()!}. Error: ${err}')
	}
	repo.pull(reload: true)!
}

pub fn (mut repo GitRepo) fetch_all() ! {
	cmd := 'cd ${repo.path()!} && git fetch --all'
	osal.execute_silent(cmd) or {
		return error('Cannot fetch repo: ${repo.path()!}. Error: ${err}')
	}
	repo.load()!
}

// Deletes the Git repository
pub fn (mut repo GitRepo) delete() ! {
	if !os.exists(repo.path()!) {
		return
	} else {
		panic('Implement deletion logic here.') // Implement the deletion logic
	}
	repo.cache_delete()!
}

// Opens SourceTree for the Git repo
pub fn (repo GitRepo) sourcetree() ! {
	sourcetree.open(path: repo.path()!)!
}

// Opens Visual Studio Code for the repo
pub fn (repo GitRepo) open_vscode() ! {
	path := repo.path()!
	mut vs_code := vscode.new(path)
	vs_code.open()!
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
