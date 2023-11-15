module bizmodel

import freeflowuniverse.crystallib.data.actionparser { Actions }
import freeflowuniverse.crystallib.baobab.smartid
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.core.pathlib
import rand

// populate the params for hr
// !!hr.employee_define
//     descr:'Junior Engineer'
//     nrpeople:'1:5,60:30'
//	   cost:'4000USD'
//	   indexation:'5%'
//     department:'engineering'
//	   cost_percent_revenue e.g. 4%, will make sure the cost will be at least 4% of revenue

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
				name = texttools.name_fix(descr) // TODO:limit len
			}
			mut cost := action.params.get_default('cost', '0.0')!
			// mut cost_year := action.params.get_currencyfloat_default('cost_year', 0.0)!
			// if cost_year > 0 {
			// 	cost = cost_year / 12
			// }
			// mut cost_growth := action.params.get_default('cost_growth', '')!
			// growth := action.params.get_default('growth', '1:1')!
			department := action.params.get_default('department', 'unknown department')!
			cost_percent_revenue := action.params.get_percentage_default('cost_percent_revenue',
				'0%')!
			nrpeople := action.params.get_default('nrpeople', '1')!

			indexation := action.params.get_percentage_default('indexation', '0%')!

			cost_center := action.params.get_default('costcenter', 'default_costcenter')!

			// // cost per person
			// namecostperson := 'nr_${name}'
			// if cost_growth.len > 0 && cost > 0 {
			// 	return error('cannot specify cost and cost growth together, chose one please.')
			// }
			if indexation > 0 {
				if cost.contains(':') {
					return error('cannot specify cost growth and indexation, should be no : inside cost param.')
				}
				mut cost_ := cost.int()
				cost2 := cost_ * (1 + indexation) * (1 + indexation) * (1 + indexation) * (1 +
					indexation) * (1 + indexation) * (1 + indexation) // 6 years, maybe need to look at months
				cost = '1:${cost},60:${cost2}'
			}

			mut costpeople_row := m.sheet.row_new(
				name: 'hr_cost_${name}'
				growth: cost
				tags: 'department:${department} hrcost'
				descr: '"cost to company per function for department ${department}'
				subgroup: 'HR cost.'
			)!
			costpeople_row.action(action: .reverse)!

			// multiply with nr of people if any
			if nrpeople != '1' {
				mut nrpeople_row := m.sheet.row_new(
					name: 'nrpeople_${name}'
					growth: nrpeople
					tags: 'hrnr'
					descr: 'amount of people for ${descr}'
					aggregatetype: .avg
				)!
				_ := costpeople_row.action(action: .multiply, rows: [nrpeople_row])!
			}
			if cost_percent_revenue > 0 {
				mut revtotal := m.sheet.row_get('revenue_total')!
				mut cost_min := revtotal.action(
					action: .multiply
					val: cost_percent_revenue
					name: 'tmp3'
					aggregatetype: .avg
				)!
				cost_min.action(action: .forwardavg)! // avg out forward looking for 12 months	
				cost_min.action(action: .reverse)!
				costpeople_row.action(
					action: .min
					rows: [cost_min]
				)!
				m.sheet.row_delete('tmp3')
			}
			employee := Employee{
				name: if name != '' { name } else { descr }
				description: descr
				department: department
				cost: cost
				cost_percent_revenue: cost_percent_revenue
				nrpeople: nrpeople
				indexation: indexation
				cost_center: cost_center
			}
			// todo: use existing id gen

			mut sid := action.params.get_default('sid', '')!
			if sid != '' {
				// sid = smartid.sid_new('')!
				// // TODO: this isn't necessary if sid_new works correctly
				// // but lets keep it in here for now until we test smartid
				// for (sid in m.employees) {
				// 	sid = smartid.sid_new('')!
				// }
				m.employees[sid] = &employee
			}
		}
	}

	mut hr_cost_row := m.sheet.group2row(
		name: 'hr_cost_total'
		include: ['hrcost']
		tags: 'pl'
		descr: 'total cost for hr'
	)!
}
