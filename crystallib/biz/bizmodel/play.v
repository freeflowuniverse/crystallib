module bizmodel

import freeflowuniverse.crystallib.core.playbook { PlayBook }
// import freeflowuniverse.crystallib.core.texttools
// import freeflowuniverse.crystallib.ui.console
// import freeflowuniverse.crystallib.biz.spreadsheet

pub fn play(mut plbook PlayBook) ! {

	// first make sure we find a run action to know the name
	mut actions4 := plbook.actions_find(actor: 'bizmodel')!

	if actions4.len == 0 {
		return
	}

	for action in actions4 {
		//biz name needs to be specified in the the bizmodel hero actions
		bizname:=action.params.get("bizname") or { 
			return error("Can't find param: 'bizname' for bizmodel macro, is a requirement argument.")
		 }
		mut sim:=get(bizname)!
		
		match action.name {
			"revenue_define" {
				sim.revenue_action(action)!
			}
			"revenue_recurring_define" {
				sim.revenue_recurring_action(action)!
			}
			"employee_define" {
				sim.employee_define_action(action)!
			}
			"funding_define" {
				sim.funding_define_action(action)!
			}
			"cost_define" {
				sim.cost_define_action(action)!
			}
			else{
				return error("Can't find macro with name: ${action.name} for macro's for bizmodel.")
			}
		}

	}

	//now we have processed the macro's, we can calculate the totals
	rlock bizmodels {
		for _,mut sim in bizmodels{
			sim.hr_total()!
			sim.cost_total()!
			sim.revenue_total()!
			sim.funding_total()!
		}
	}
}
