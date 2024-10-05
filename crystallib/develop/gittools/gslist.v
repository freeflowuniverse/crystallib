
module gittools
import freeflowuniverse.crystallib.ui.console

// Print repositories based on certain criteria
pub fn (mut gitstructure GitStructure) repos_print(args ReposGetArgs) ! {
	console.print_debug(' #### overview of repositories:')
	console.print_debug('')
	mut r := [][]string{}
	for _, g in gitstructure.repos_get(args)! {
		mut s := ''
		if g.need_commit() {
			s += 'COMMIT,'
		}
		if g.need_pull() {
			s += 'PULL,'
		}
		if g.need_push() {
			s += 'PUSH,'
		}
		s = s.trim(',')
		if g.status_local.tag.len>0{
			r << [' - ${g.path_relative()!}', '[[${g.status_local.tag}]]', s]
		}else{
			r << [' - ${g.path_relative()!}', '[${g.status_local.branch}]', s]
		}
		
	}
	console.clear()
	console.print_lf(1)
	if args.str().len > 0 {
		console.print_header('repositories: ${gitstructure.coderoot.path} [${args.str()}]')
	} else {
		console.print_header('repositories: ${gitstructure.coderoot.path}')
	}
	console.print_lf(1)
	console.print_array(r, '  ', true)
	console.print_lf(5)
}
