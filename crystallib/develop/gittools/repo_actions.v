module gittools

import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.develop.vscode
import freeflowuniverse.crystallib.develop.sourcetree
import os

fn (repo GitRepo) get_clone_cmd(args CloneArgs) !string {
	url := if args.forcehttp { repo.get_http_url()! } else { repo.get_repo_url()! }
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

// Checkout specific tag
fn (mut repo GitRepo) checkout_tag(tag string) ! {
	cmd := 'cd ${repo.get_path()!} && git checkout ${tag}'
	osal.execute_silent(cmd) or {
		return error('Cannot checkout tag ${tag} for repo: ${repo.get_path()!}. Error: ${err}')
	}
}

// Update submodules
fn (mut repo GitRepo) update_submodules() ! {
	cmd := 'cd ${repo.get_path()!} && git submodule update --init --recursive'
	osal.execute_silent(cmd) or {
		return error('Cannot update submodules for repo: ${repo.get_path()!}. Error: ${err}')
	}
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

pub fn (mut repo GitRepo) fetch_all() ! {
	cmd := 'cd ${repo.get_path()!} && git fetch --all'
	osal.execute_silent(cmd) or {
		return error('Cannot fetch repo: ${repo.get_path()!}. Error: ${err}')
	}
	repo.load()!
}

// Opens SourceTree for the Git repo
pub fn (repo GitRepo) sourcetree() ! {
	sourcetree.open(path: repo.get_path()!)!
}

// Opens Visual Studio Code for the repo
pub fn (repo GitRepo) open_vscode() ! {
	path := repo.get_path()!
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
