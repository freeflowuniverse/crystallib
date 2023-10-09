module gittools

import freeflowuniverse.crystallib.ui as gui
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.console

pub fn (mut gitstructure GitStructure) repos_print(args ReposGetArgs) {
	mut r := [][]string{}
	for g in gitstructure.repos_get(args) {
		need_commit := g.needcommit() or { panic('issue in repo need_commit. ${err}') }
		need_pull := g.needpull() or { panic('issue in repo need_pull. ${err}') }
		need_push := g.needpush() or { panic('issue in repo need_push. ${err}') }
		pr := g.path.shortpath()
		mut s := ''
		if need_commit {
			s += 'COMMIT,'
		}
		if need_pull {
			s += 'PULL,'
		}
		if need_push {
			s += 'PUSH,'
		}
		s = s.trim(',')
		r << [' - ${pr}', '[${g.addr.branch}]', s]
	}
	// println(args)
	console.clear()
	println('\n ==== repositories on your disk ===\n')
	texttools.print_array2(r, '  ', true)
	println('')
}

[params]
pub struct ReposActionsArgs {
pub mut:
	filter         string // if used will only show the repo's which have the filter string inside
	repo           string
	account        string
	provider       string
	print          bool = true
	pull           bool // means when getting new repo will pull even when repo is already there
	pullreset      bool // means we will force a pull and reset old content	
	commit         bool
	commitpull     bool
	commitpush     bool
	commitpullpush bool
	msg            string
	delete         bool // remove the repo
	script         bool = true // run non interactiv
	cachereset     bool
}

// filter   string // if used will only show the repo's which have the filter string inside .
// repo     string .
// account  string .
// provider string .
// print bool = true  //default .
// pull     bool // means when getting new repo will pull even when repo is already there .
// pullreset bool // means we will force a pull and reset old content .
// commit bool .
// commitpush bool .
// commitpull bool .
// commitpullpush bool .
// msg string .
// delete bool (remove the repo) .
// script bool (run non interactive) .
// root string //the location of coderoot if its another one .
pub fn (mut gs GitStructure) actions(args_ ReposActionsArgs) ! {
	mut args := args_

	mut ui := gui.new()!

	for g in gs.repos_get(
		filter: args.filter
		name: args.repo
		account: args.account
		provider: args.provider
	) {
		if args.cachereset {
			g.refresh(reload: true)!
		}
	}

	if args.print {
		gs.repos_print(
			filter: args.filter
			name: args.repo
			account: args.account
			provider: args.provider
		)
	}

	mut need_commit := false
	mut need_pull := false
	mut need_push := false
	for g in gs.repos_get(
		filter: args.filter
		name: args.repo
		account: args.account
		provider: args.provider
	) {
		if g.needcommit()! {
			need_commit = true
		}
		if g.needpull()! {
			need_pull = true
		}
		if g.needpush()! {
			need_push = true
		}
		// println(" ---- ${g.addr.name} $need_commit $need_pull  $need_push")		
	}

	if args.print {
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
			println(out + ' ** \n')
		}
	}

	if !(args.script) {
		mut ok := true
		// need to ask if ok
		if args.pullreset && need_pull {
			ok0 := ui.ask_yesno(question: 'ok to pull and reset the changes?')
			ok = ok && ok0
		}
		if args.commitpullpush {
			if need_commit || need_pull || need_push {
				ok0 := ui.ask_yesno(question: 'ok to commit, pull and push the changes?')
				ok = ok && ok0
			}
		}
		if args.commitpull {
			if need_commit || need_pull {
				ok0 := ui.ask_yesno(question: 'ok to commit, pull the changes?')
				ok = ok && ok0
			}
		}
		if args.delete {
			ok0 := ui.ask_yesno(question: 'ok to delete, the repos?')
			ok = ok && ok0
		}
		if ok == false {
			return error('cannot continue with action, you asked me to stop.\n${args}')
		}
	}

	mut changed := false

	for g in gs.repos_get(
		filter: args.filter
		name: args.repo
		account: args.account
		provider: args.provider
	) {
		if args.commit || args.commitpush || args.commitpullpush || args.commitpull {
			cod := g.needcommit()!
			if cod {
				mut msg := args.msg
				if msg.len == 0 {
					if args.script {
						return error('message needs to be specified for commit.')
					}
					msg = ui.ask_question(
						question: 'commit message for repo: ${g.addr.account}/${g.addr.name} '
					)
				}
				println(' - commit ${g.addr.account}/${g.addr.name}')
				g.commit(msg)!
				changed = true
			} else {
				println(' - no need to commit, no changes for ${g.addr.account}/${g.addr.name}')
			}
		}
		if args.pull || args.pullreset || args.commitpullpush || args.commitpull {
			if args.pullreset {
				println(' - remove changes ${g.addr.account}/${g.addr.name}')
				g.remove_changes()!
			}
			println(' - pull ${g.addr.account}/${g.addr.name}')
			g.pull()!
			changed = true
		}
		if args.commitpush || args.commitpullpush {
			println(' - push ${g.addr.account}/${g.addr.name}')
			g.push()!
			changed = true
		}
	}

	if changed {
		console.clear()
		println('\nCompleted required actions.\n')

		if args.print {
			gs.repos_print(
				filter: args.filter
				name: args.repo
				account: args.account
				provider: args.provider
			)
		}
	}
}
