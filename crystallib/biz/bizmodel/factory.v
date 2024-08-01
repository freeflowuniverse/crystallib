module bizmodel

import freeflowuniverse.crystallib.biz.spreadsheet
// import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.threefold.grid4.cloudslices

__global (
	bizmodels shared map[string]&BizModel
)



pub struct BizModel {
pub mut:
	sheet     spreadsheet.Sheet
	params    BizModelArgs
	employees map[string]&Employee
}


@[params]
pub struct BizModelArgs {
pub mut:
	name          string = 'default' // name of simulation
	path          string
	git_url       string
	git_reset     bool
	git_pull      bool
	mdbook_source string
	mdbook_name   string // if empty will be same as name of simulation
	mdbook_path   string
	mdbook_dest   string // if empty is /tmp/mdbooks/$name
}

pub fn new(args_ BizModelArgs) !BizModel {
	mut args := args_

	// mut cs := currency.new()
	mut sh := spreadsheet.sheet_new(name: 'bizmodel_${args.name}')!
	mut bizmodel := BizModel{
		name: args.name
		sheet: &sh
		params: args
		// currencies: cs
	}

	if args.name == '' {
		return error('simulation needs to have a name')
	}

	args.name = texttools.name_fix(args.name)

	if args.mdbook_name == '' {
		args.mdbook_name = args.name
	}

	if args.git_url.len > 0 {
		args.path = gittools.code_get(
			url: args.git_url
			pull: args.git_pull
			reset: args.git_reset
			reload: false
		)!
	}

	simulator_set(bizmodel)
	bizmodel.load()!

	return bizmodel
}

// get sheet from global
pub fn simulator_get(name string) !&BizModel {
	rlock bizmodels {
		if name in bizmodels {
			return bizmodels[name]
		}
	}
	return error("cann't find tfgrid simulator:'${name}' in global bizmodels")
}

// remember sheet in global
pub fn simulator_set(bizmodel BizModel) {
	lock bizmodels {
		bizmodels[bizmodel.name] = &bizmodel
	}
	spreadsheet.sheet_set(bizmodel.sheet)
}

// load the mdbook content from path or git
pub fn (mut self BizModel) load() ! {
	console.print_debug('SIMULATOR LOAD ${self.params.name}')

	mut plbook := playbook.new(path: self.params.path)!

	self.play(mut plbook)!
}
