module bizmodel

import freeflowuniverse.crystallib.core.playbook { PlayBook }
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.biz.spreadsheet

pub fn play(mut plbook PlayBook) ! {
	mut sheet_name := ''
	// first make sure we find a run action to know the name
	mut actions4 := plbook.actions_find(actor: 'tfgrid_simulator')!

	if actions4.len == 0 {
		return
	}

	for mut action in actions4 {
		if action.name == 'run' {
			sheet_name = action.params.get('name')!
		}
	}

	if sheet_name == '' {
		return error("can't find run action for tfgrid_simulator, name needs to be specified as arg.")
	}

	mut sh := spreadsheet.sheet_new(name: 'tfgridsim_${sheet_name}')!
	mut sim := BizModel{
		sheet: &sh
		// currencies: cs
	}

	simulator_set(sim)

	sim.play(mut plbook)!
}

pub fn (mut self BizModel) play(mut plbook PlayBook) ! {
	self.revenue_actions(plbook)!
	self.hr_actions(plbook)!
	self.funding_actions(plbook)!
	self.overhead_actions(plbook)!

	simulator_set(self)

	println(self.sheet)

	// if true{
	// 	panic("arym")
	// }
}
