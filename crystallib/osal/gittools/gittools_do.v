module gittools

import freeflowuniverse.crystallib.ui as gui
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.ui.console


import os

pub const gitcmds = 'clone,commit,pull,push,delete,reload,list,edit,sourcetree'

pub fn (mut gitstructure GitStructure) repos_print(args ReposGetArgs) ! {
	mut r := [][]string{}
	for mut g in gitstructure.repos_get(args) {
		st := g.status()!
		pr := g.path.shortpath()
		mut s := ''
		if st.need_commit {
			s += 'COMMIT,'
		}
		if st.need_pull {
			s += 'PULL,'
		}
		if st.need_push {
			s += 'PUSH,'
		}
		s = s.trim(',')
		r << [' - ${pr}', '[${g.addr.branch}]', s]
	}
	console.clear()
	console.print_header('repositories on coderoot: ${gitstructure.config.root}')
	console.print_array(r, '  ', true)
	console.lf()
}

@[params]
pub struct ReposActionsArgs {
pub mut:
	cmd      string // clone,commit,pull,push,delete,reload,list,edit,sourcetree
	filter   string // if used will only show the repo's which have the filter string inside
	repo     string
	account  string
	provider string
	msg      string
	url      string
	pull     bool
	script   bool = true // run non interactive
	reset    bool = true // means we will lose changes (only relevant for clone, pull)
}

// do group actions on repo
// args
//```
// cmd      string // clone,commit,pull,push,delete,reload,list,edit,sourcetree
// filter   string // if used will only show the repo's which have the filter string inside
// repo     string
// account  string
// provider string
// msg      string
// url      string
// pull     bool
// script   bool = true // run non interactive
// reset    bool = true // means we will lose changes (only relevant for clone, pull)
//```
pub fn (mut gs GitStructure) do(args_ ReposActionsArgs) ! {
	mut args := args_
	// println(args)

	if args.repo == '' && args.account == '' && args.provider == '' && args.filter == '' {
		curdir := os.getwd()
		mut curdiro := pathlib.get_dir(path: curdir, create: false)!
		mut parentpath := curdiro.parent_find('.git') or { pathlib.Path{} }
		if parentpath.path != '' {
			r0 := gs.repo_from_path(parentpath.path)!
			args.repo = r0.addr.name
			args.account = r0.addr.account
			args.provider = r0.addr.provider
		}
	}

	args.cmd = args.cmd.trim_space().to_lower()

	mut ui := gui.new()!

	if args.cmd == 'reload' {
		console.print_header(' - reload gitstructure ${gs.name()}')
		gs.reload()!
		return
	}

	if args.cmd == 'list' {
		gs.repos_print(
			filter: args.filter
			name: args.repo
			account: args.account
			provider: args.provider
		)!
		return
	}

	mut repos := gs.repos_get(
		filter: args.filter
		name: args.repo
		account: args.account
		provider: args.provider
	)

	if args.url.len > 0 {
		mut locator := gs.locator_new(args.url)!
		// println(locator)
		mut g := gs.repo_get(locator: locator)!
		g.load()!
		if args.cmd == 'pull' || args.pull {
			g.pull()!
		}
		if args.cmd == 'push' {
			st := g.status()!
			if st.need_commit {
				if args.msg.len == 0 {
					return error('please specify message with -m ...')
				}
				g.commit_pull_push(msg: args.msg)!
			}
			g.push()!
		}
		if args.reset {
			g.remove_changes()!
		}
		if args.cmd == 'pull' || args.cmd == 'clone' || args.cmd == 'push' {
			return
		}
		repos = [g]
	}

	if args.cmd in 'sourcetree,edit'.split(',') {
		if repos.len == 0 {
			return error('please specify at least 1 repo for cmd:${args.cmd}')
		}
		if repos.len > 4 {
			return error('more than 4 repo found for cmd:${args.cmd}')
		}
		for r in repos {
			if args.cmd == 'edit' {
				r.vscode()!
			}
			if args.cmd == 'sourcetree' {
				r.sourcetree()!
			}
		}
		return
	}

	if args.cmd in 'pull,push,commit,delete'.split(',') {
		gs.repos_print(
			filter: args.filter
			name: args.repo
			account: args.account
			provider: args.provider
		)!

		mut need_commit := false
		mut need_pull := false
		mut need_push := false

		if repos.len == 0 {
			console.print_header(' - nothing to do.')
			return
		}

		// check on repos who needs what
		for mut g in repos {
			g.load()!
			st := g.status()!
			// println(st)
			need_commit = st.need_commit || need_commit
			if args.cmd == 'push' && need_commit {
				need_push = true
			}
			need_pull = args.cmd in 'pull,push'.split(',') // always do pull when push and pull
			need_push = args.cmd == 'push' && (st.need_push || need_push)
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
			println(out + ' ** \n')
			if args.script {
				ok = true
			} else {
				ok = ui.ask_yesno(question: 'Is above ok?')!
			}
		}
		if args.cmd == 'delete' {
			if args.script {
				ok = true
			} else {
				ok = ui.ask_yesno(question: 'Is it ok to delete above repos? (DANGEROUS)')!
			}
		}

		if ok == false {
			return error('cannot continue with action, you asked me to stop.\n${args}')
		}

		mut changed := false

		for mut g in repos {
			st := g.status()!
			need_commit_repo := (st.need_commit || need_commit)
				&& args.cmd in 'commit,pull,push'.split(',')
			need_pull_repo := args.cmd in 'pull,push'.split(',') // always do pull when push and pull
			need_push_repo := args.cmd in 'push'.split(',') && (st.need_push || need_push)
			// println(" --- git_do ${g.addr.name} ${st.need_commit} ${st.need_pull}  ${st.need_push}")		

			if need_commit_repo {
				mut msg := args.msg
				if msg.len == 0 {
					if args.script {
						return error('message needs to be specified for commit.')
					}
					msg = ui.ask_question(
						question: 'commit message for repo: ${g.addr.account}/${g.addr.name} '
					)!
				}
				console.print_header(' - commit ${g.addr.account}/${g.addr.name}')
				g.commit(msg: msg, reload: true)!
				changed = true
			}
			if need_pull_repo {
				if args.reset {
					console.print_header(' - remove changes ${g.addr.account}/${g.addr.name}')
					g.remove_changes()!
				}
				console.print_header(' - pull ${g.addr.account}/${g.addr.name}')
				g.pull()!
				changed = true
			}
			if need_push_repo {
				console.print_header(' - push ${g.addr.account}/${g.addr.name}')
				g.push()!
				changed = true
			}
			if args.cmd == 'delete' {
				g.delete()!
				changed = true
			}
		}

		if changed {
			// console.clear()
			console.print_header('\nCompleted required actions.\n')

			gs.repos_print(
				filter: args.filter
				name: args.repo
				account: args.account
				provider: args.provider
			)!
		}

		return
	}
	// end for the commit, pull, push, delete

	$if debug {
		print_backtrace()
	}
	return error('did not find cmd: ${args.cmd}')
}
