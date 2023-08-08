module bizmodel

import freeflowuniverse.crystallib.baobab.actions {Actions}
import freeflowuniverse.crystallib.texttools


// populate the params for hr
// !!hr.employee_define
//     descr:'Junior Engineer'
//     nrpeople:'1:5,60:30' 
//	   cost:'4000USD' 
//	   indexation:'5%'
//     department:'engineering'
fn (mut m BizModel) hr_actions(actions_ Actions) ! {
	mut actions2 := actions_.filtersort(actor: 'hr')!
	for action in actions2 {
		if action.name == 'employee_define' {
			mut name := action.params.get_default('name', '')!
			mut descr := action.params.get_default('descr', '')!
			if descr.len == 0 {
				descr = action.params.get('description')!
			}
			if name.len == 0 {
				// make name ourselves
				name = texttools.name_fix(descr) //TODO:limit len
			}
			mut cost := action.params.get_default('cost', "0.0")!
			// mut cost_year := action.params.get_currencyfloat_default('cost_year', 0.0)!
			// if cost_year > 0 {
			// 	cost = cost_year / 12
			// }
			// mut cost_growth := action.params.get_default('cost_growth', '')!
			// growth := action.params.get_default('growth', '1:1')!
			department := action.params.get_default('department', 'unknown department')!
			indexation := action.params.get_percentage_default('indexation', '0%')!

			// // cost per person
			// namecostperson := 'nr_${name}'
			// if cost_growth.len > 0 && cost > 0 {
			// 	return error('cannot specify cost and cost growth together, chose one please.')
			// }
			// if indexation > 0 {
			// 	if cost_growth.len > 0 {
			// 		return error('cannot specify cost growth and indexation')
			// 	}
			// 	cost2 := cost * (1 + indexation) * (1 + indexation) * (1 + indexation) * (1 +
			// 		indexation) * (1 + indexation) * (1 + indexation) // 6 years, maybe need to look at months
			// 	cost_growth = '1:${cost},60:${cost2}'
			// }
			// if cost_growth.len == 0 && cost > 0 {
			// 	cost_growth = '1:${cost}'
			// }
			// mut costotal := m.sheet.row_new(
			// 	name: 'cost_total_${name}'
			// 	growth: cost_growth
			// 	tags: 'cat:hr cost:total'
			// 	descr: '"cost to company per function.'
			// 	subgroup: 'HR cost total.'
			// )!

			// // multiply with nr of people if any
			// if growth != '1:1' {
			// 	mut nr := m.sheet.row_new(
			// 		name: 'nr_${name}'
			// 		growth: growth
			// 		tags: 'cat:hr cost:item'
			// 		descr: 'amount of ${descr}'
			// 		subgroup: 'NR of people on payroll'
			// 		aggregatetype: .max
			// 	)!
			// 	costotal.action(rows: [nr], action: .multiply)!
			// }
		}
	}
}
