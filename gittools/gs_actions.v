module gittools
import freeflowuniverse.crystallib.ui as gui
import freeflowuniverse.crystallib.texttools

pub fn (mut gitstructure GitStructure) repos_print(args ReposGetArgs) {
	mut r := [][]string{}
	for g in gitstructure.repos_get(args) {
		changed := g.changes() or { panic('issue in repo changes. ${err}') }
		pr := g.path_relative()
		if changed {
			r << [' - ${pr}', '${g.addr.branch}', 'CHANGED']
		} else {
			r << [' - ${pr}', '${g.addr.branch}', '']
		}
	}
	texttools.print_array2(r, '  ', true)
}



[params]
pub struct ReposActionsArgs {
pub mut:
	filter   string // if used will only show the repo's which have the filter string inside
	repo     string
	account  string
	provider string
	print 	 bool = true
	pull     bool // means when getting new repo will pull even when repo is already there
	pullreset    bool // means we will force a pull and reset old content	
	commit bool
	commitpush bool
	commitpullpush bool
	msg string
	delete bool //remove the repo
	script bool = true //run non interactive
	coderoot string //the location of coderoot if its another one	
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
// commitpullpush bool .
// msg string .
// delete bool (remove the repo) .
// script bool (run non interactive) .
// coderoot string //the location of coderoot if its another one .
pub fn (mut gs GitStructure) actions(args_ ReposActionsArgs)! {
	mut args:=args_

	mut ui := gui.new()!

	if args.print{
		gs.repos_print(
			filter:args.filter
			name:args.repo
			account:args.account
			provider:args.provider
		)
	}

	if !(args.script){
		mut ok:=true
		//need to ask if ok
		if args.pullreset {
			ok0:=ui.ask_yesno(question:"ok to pull and reset the changes?")
			ok=ok && ok0
		}
		if args.commitpullpush {
			ok0:=ui.ask_yesno(question:"ok to commit, pull and push the changes?")
			ok=ok && ok0
		}	
		if args.delete {
			ok0:=ui.ask_yesno(question:"ok to delete, the repos?")
			ok=ok && ok0
		}				
		if ok==false{
			return error("cannot continue with action, you asked me to stop.\n$args")
		}
	}

	for mut g in gs.repos_get(
			filter:args.filter
			name:args.repo
			account:args.account
			provider:args.provider		
		) {
		if args.commit || args.commitpush || args.commitpullpush {
			if args.msg.len==0{
				if args.script{
					return error("message needs to be specified for commit.")
				}				
				args.msg=ui.ask_question(question:"commit message")
			}
			g.commit(args.msg)!
		}
		if args.pull || args.pullreset || args.commitpullpush{
			g.pull()!
		}
		if args.commitpush || args.commitpullpush{
			g.push()!
		}

	}	

}
