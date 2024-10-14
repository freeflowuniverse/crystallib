module gittools

import freeflowuniverse.crystallib.ui as gui
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import os

pub const gitcmds = 'clone,commit,pull,push,delete,reload,list,edit,sourcetree,cd'

// Perform group actions on repositories based on the provided arguments.
// The arguments allow filtering, specifying repositories, and performing git commands like clone, pull, push, etc.
pub fn (mut gs GitStructure) do(args_ ReposActionsArgs) !string {
	mut args := args_
	console.print_debug('git do ${args}')

	// If no repo, account, provider, or filter is provided, try to find current git repo based on working directory
	if args.repo == '' && args.account == '' && args.provider == '' && args.filter == '' {
		curdir := os.getwd()
		mut curdiro := pathlib.get_dir(path: curdir, create: false)!
		mut parentpath := curdiro.parent_find('.git') or { pathlib.Path{} }
		if parentpath.path != '' {
			gitlocation := gs.gitlocation_from_path(parentpath.path)!
			args.repo = gitlocation.name
			args.account = gitlocation.account
			args.provider = gitlocation.provider
		}
	}

	args.cmd = args.cmd.trim_space().to_lower()

	mut ui := gui.new()!

	match args.cmd {
		'reload' {
			console.print_header(' - reload gitstructure ${gs.key}')
			gs.load()!
			return ''
		}
		'list' {
			gs.repos_print(
				filter:   args.filter
				name:     args.repo
				account:  args.account
				provider: args.provider
			)!
			return ''
		}
		else {}
	}

	mut repos := gs.get_repos(
		filter:   args.filter
		name:     args.repo
		account:  args.account
		provider: args.provider
	)!

	// Handle commands that work with a specified URL
	if args.url.len > 0 {
		mut locator := gs.gitlocation_from_url(args.url)!
		if args.branch.len > 0 {
			locator.branch = args.branch
		}

		mut repo := gs.repo_get_from_locator(locator)!
		repo_path := repo.get_path()!
		repo.load()!

		if args.cmd == 'cd' {
			return repo_path
		}
		if args.reset {
			repo.remove_changes()!
		}
		if args.cmd == 'pull' || args.pull {
			repo.pull(branch: args.branch, recursive: args.recursive, tag: args.tag)!
		}
		if args.cmd == 'push' {
			if repo.need_commit()! {
				if args.msg.len == 0 {
					return error('please specify a commit message with -m ...')
				}
				repo.commit(msg: args.msg)!
			}
			repo.push()!
		}
		if args.cmd in ['pull', 'clone', 'push'] {
			console.print_debug('git do ok, on path ${repo_path}')
			return repo_path
		}
		repos = [repo]
	}

	// Handle commands related to 'sourcetree' and 'edit'
	if args.cmd in ['sourcetree', 'edit'] {
		if repos.len == 0 {
			return error('please specify at least 1 repo for cmd: ${args.cmd}')
		}
		if repos.len > 4 {
			return error('more than 4 repos found for cmd: ${args.cmd}')
		}
		for r in repos {
			match args.cmd {
				'edit' {
					r.open_vscode()!
				}
				'sourcetree' {
					r.sourcetree()!
				}
				else {}
			}
		}
		return ''
	}

	// Handle commands related to 'pull', 'push', 'commit', and 'delete'
	if args.cmd in ['pull', 'push', 'commit', 'delete'] {
		gs.repos_print(
			filter:   args.filter
			name:     args.repo
			account:  args.account
			provider: args.provider
		)!

		mut need_commit := false
		mut need_pull := false
		mut need_push := false

		if repos.len == 0 {
			console.print_header(' - nothing to do.')
			return ''
		}

		// Check which repositories need actions
		for mut g in repos {
			g.load()!
			need_commit = g.need_commit()! || need_commit
			if args.cmd == 'push' && need_commit {
				need_push = true
			}
			need_pull = args.cmd in ['pull', 'push'] // always do pull when push and pull
			need_push = args.cmd == 'push' && (g.need_push()! || need_push)
		}

		mut ok := false
		if need_commit || need_pull || need_push {
			mut out := '\n ** NEED TO '
			if need_commit {
				out += 'COMMIT '
			}
			if need_pull {
				out += 'PULL '
			}
			if need_push {
				out += 'PUSH '
			}
			if args.reset {
				out += ' (changes will be lost!)'
			}
			console.print_debug(out + ' ** \n')
			if args.script {
				ok = true
			} else {
				ok = ui.ask_yesno(question: 'Is the above action okay?')!
			}
		}
		if args.cmd == 'delete' {
			if args.script {
				ok = true
			} else {
				ok = ui.ask_yesno(
					question: 'Is it okay to delete the selected repositories? (DANGEROUS)'
				)!
			}
		}

		if !ok {
			return error('Action stopped as per request.\n${args}')
		}

		mut changed := false

		// Perform required actions on repositories
		for mut g in repos {
			if g.need_commit()! && args.cmd in ['commit', 'pull', 'push'] {
				mut msg := args.msg
				if msg.len == 0 {
					if args.script {
						return error('Commit message needs to be specified.')
					}
					msg = ui.ask_question(
						question: 'Commit message for repo: ${g.account}/${g.name} '
					)!
				}
				console.print_header(' - commit ${g.account}/${g.name}')
				g.commit(msg: msg, reload: true)!
				changed = true
			}
			if need_pull {
				if args.reset {
					console.print_header(' - remove changes ${g.account}/${g.name}')
					g.remove_changes()!
				}
				console.print_header(' - pull ${g.account}/${g.name}')
				g.pull()!
				changed = true
			}
			if need_push {
				console.print_header(' - push ${g.account}/${g.name}')
				g.push()!
				changed = true
			}
			if args.cmd == 'delete' {
				g.delete()!
				changed = true
			}
		}

		if changed {
			console.print_header('\nCompleted required actions.\n')
			gs.repos_print(
				filter:   args.filter
				name:     args.repo
				account:  args.account
				provider: args.provider
			)!
		}

		return ''
	}

	return error('Unknown command: ${args.cmd}')
}
