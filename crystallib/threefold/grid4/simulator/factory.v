module simulator

import freeflowuniverse.crystallib.biz.spreadsheet
// import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.core.texttools
// import freeflowuniverse.crystallib.data.doctree
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.threefold.grid4.cloudslices

__global (
	tfgridsimulators shared map[string]&Simulator
)


pub struct Simulator {
pub mut:
	name string
	sheet     &spreadsheet.Sheet
	params    SimulatorArgs
	nodes map[string]&cloudslices.Node
}

@[params]
pub struct SimulatorArgs {
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

pub fn new(args_ SimulatorArgs) !Simulator {
	mut args := args_

	// mut cs := currency.new()
	mut sh := spreadsheet.sheet_new(name:"tfgridsim_${args.name}")!
	mut sim := Simulator{
		name:args.name
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

	// tree_name := 'simulation_${args.name}'
	// mut tree := doctree.new(name: tree_name)!

	// mp := macroprocessor_new(args_.name)
	// tree.macroprocessor_add(mp)!

	if args.git_url.len > 0 {
		args.path = gittools.code_get(
			url: args.git_url
			pull: args.git_pull
			reset: args.git_reset
			reload: false
		)!
	}

	simulator_set(sim)
	sim.load()!

	return sim
}


//get sheet from global
pub fn simulator_get(name string) !&Simulator {
	rlock tfgridsimulators {
		if name in tfgridsimulators {
			return tfgridsimulators[name]
		}
	}
	return error("cann't find tfgrid simulator:'${name}' in global tfgridsimulators")
}

//remember sheet in global
pub fn simulator_set(sim Simulator) {
	lock tfgridsimulators {
		tfgridsimulators[sim.name] = &sim
	}
	spreadsheet.sheet_set(sim.sheet)

}



//load the mdbook content from path or git
pub fn (mut self Simulator) load() ! {
	console.print_debug('SIMULATOR LOAD ${self.params.name}')

	mut plbook := playbook.new(path: self.params.path)!

	self.play(mut plbook)!

}

