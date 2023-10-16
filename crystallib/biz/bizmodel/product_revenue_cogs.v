module bizmodel

import freeflowuniverse.crystallib.core.actionsparser { Actions }
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.paramsparser

// possible parameters for non recurring
//
// - name, e.g. for a specific project.
// - descr, description of the revenue line item.
// - revenue_item, revenue for 1 item '1000USD', can change over time e.g. 0:1000USD,10:1200USD.
// - revenue_nr: how many items are sold of the revenue specification e.g. 1:100,60:200 means growing from 100 to 200 over 6Y.
// - revenue_time, revenue per specific times, e.g. month 10, OEM deal of 1000, month 20 another one would be '10:1000,20:1000'.
// - revenue_setup_delay: how many months delay on cost of goods, default is 0 months.
// - revenue_monthly_delay
// - cogs_perc: what is percentage of the cogs (can change over time) e.g. 0:5%,12:10%.
//
fn (mut m BizModel) revenue_actions(actions_ Actions) ! {
	mut actions2 := actions_.filtersort(actor: 'revenue')!
	for action in actions2 {
		if action.name == 'define' {
			// !!revenue.define
			//     descr:'3NODE License Sales Recurring Basic'
			//     revenue_item:'1:2,60:5'
			//     revenue_nr:'10:1000,24:2000,60:40000'
			//     cogs_perc: '10%'
			//
			// - name, e.g. for a specific project
			// - descr, description of the revenue line item
			// - revenue_item, revenue for 1 item '1000usd'
			// - revenue_nr: how many items are sold of the revenue specification e.g. 1:100,60:200 means growing from 100 to 200 over 6Y
			// - revenue_time, revenue per specific times, e.g. month 10, OEM deal of 1000, month 20 another one would be '10:1000,20:1000'
			// - revenue_growth: how does revenue grow over time e.g. 1:10000USD,20:20000USD
			// - rev_delay_month: how many months delay on cost of goods, default is 0 months
			// - cogs_perc: what is percentage of the cogs (can change over time)
			//

			mut name := action.params.get_default('name', '')!
			mut descr := action.params.get_default('descr', '')!
			if descr.len == 0 {
				descr = action.params.get('description')!
			}
			if name.len == 0 {
				// make name ourselves
				name = texttools.name_fix(descr)
			}
			mut revenue_item_param := action.params.get_default('revenue_item', '')!
			mut revenue_nr_param := action.params.get_default('revenue_nr', '')!

			mut revenue_time_param := action.params.get_default('revenue_time', '')!
			mut revenue_growth_param := action.params.get_default('revenue_growth', '')!

			revenue_monthly_delay_param := action.params.get_int_default('revenue_monthly_delay',
				0)!
			revenue_setup_delay_param := action.params.get_int_default('revenue_setup_delay',
				0)!
			cogs_perc_param := action.params.get_default('cogs_perc', '0%')!

			mut revenue_item := m.sheet.row_new(
				name: '${name}_rev_per_item'
				growth: revenue_item_param
				tags: 'rev name:${name}'
				descr: 'What is revenue for 1 item.'
				aggregatetype: .avg
			)!
			mut revenue_nr := m.sheet.row_new(
				name: '${name}_rev_nr_items'
				growth: revenue_nr_param
				tags: 'rev  name:${name}'
				descr: 'How many of the items are being sold per month.'
			)!

			// multiply rev item with rev nr to get to total
			mut revenue_item_total := revenue_item.action(
				name: '${name}_rev_items_aggregated'
				rows: [revenue_nr]
				action: .multiply
				tags: 'rev name:${name}'
				descr: 'What is revenue for all items.'
				aggregatetype: .sum
			)!

			mut revenue_time := m.sheet.row_new(
				name: '${name}_rev_one_off'
				growth: revenue_time_param
				tags: 'rev  name:${name}'
				descr: 'Onetime revenues.'
				aggregatetype: .sum
				extrapolate: false
			)!

			mut revenue_growth := m.sheet.row_new(
				name: '${name}_rev_monthly_growth'
				growth: revenue_growth_param
				tags: 'rev  name:${name}'
				descr: 'Monthly Growing revenues.'
				aggregatetype: .sum
			)!
			// println(revenue_time_param)
			// println(m.sheet.wiki()!)
			// println(revenue_growth_param)
			// println(revenue_growth)
			// if true{panic("sdsd")}

			mut cogs_perc := m.sheet.row_new(
				name: '${name}_cogs_perc'
				growth: cogs_perc_param
				tags: 'name:${name} cogs'
				descr: 'Percentage of cogs'
				aggregatetype: .avg
			)!

			mut revenue_total := m.sheet.row_new(
				name: '${name}_rev_total'
				tags: 'revtotal name:${name}'
				growth: '1:0.0' // init as 0
				descr: 'Total revenue for this service/product.'
			)!
			revenue_total.action(
				action: .add
				rows: [revenue_time, revenue_item_total, revenue_growth]
			)!

			mut cogs_total := m.sheet.row_new(
				name: '${name}_cogs_total'
				tags: 'cogs total name:${name}'
				growth: '1:0.0' // init as 0
				descr: 'Total cogs for product.'
			)!
			cogs_total.action(
				action: .multiply
				rows: [revenue_total, cogs_perc]
			)!
			cogs_total.action(action: .reverse)!

			// mut margin_total := m.sheet.row_new(
			// 	name: '${name}_margin_total'
			// 	tags: 'margin total name:${name}'
			// 	growth: '1:0.0' // init as 0
			// 	descr: 'Total margin for product.'
			// )!
			_ := revenue_total.action(
				action: .add
				rows: [cogs_total]
				name: '${name}_margin_total'
				tags: 'margin margintotal name:${name}'
				descr: 'Total margin for product.'
			)!
		} else if action.name == 'recurring_define' {
			// - name, e.g. for a specific project
			// - descr, description of the revenue line item
			// - revenue_setup, revenue for 1 item '1000usd'
			// - revenue_setup_delay
			// - revenue_monthly, revenue per month for 1 item
			// - revenue_monthly_delay, how many months before monthly revenue starts
			// - cogs_setup, cost of good for 1 item at setup
			// - cogs_setup_perc: what is percentage of the cogs (can change over time) for setup e.g. 0:50%
			// - cogs_monthly, cost of goods for the monthly per 1 item
			// - cogs_monthly_perc: what is percentage of the cogs (can change over time) for monthly e.g. 0:5%,12:10%
			// - nr_sold: how many do we sell per month (is in growth format e.g. 10:100,20:200)
			// - nr_months: how many months is recurring

			mut name := action.params.get_default('name', '')!
			mut descr := action.params.get_default('descr', '')!
			if descr.len == 0 {
				descr = action.params.get('description')!
			}
			if name.len == 0 {
				// make name ourselves
				name = texttools.name_fix(descr)
			}

			// revenue
			revenue_setup_param := action.params.get_default('revenue_setup', '')!
			revenue_monthly_param := action.params.get_default('revenue_monthly', '')!
			revenue_monthly_delay_param := action.params.get_int_default('revenue_monthly_delay',
				0)!
			revenue_setup_delay_param := action.params.get_int_default('revenue_setup_delay',
				0)!

			// cogs
			cogs_setup_param := action.params.get_default('cogs_setup', '')!
			cogs_monthly_param := action.params.get_default('cogs_monthly', '')!
			cogs_setup_perc_param := action.params.get_default('cogs_setup_perc', '0%')!
			cogs_monthly_perc_param := action.params.get_default('cogs_monthly_perc',
				'0%')!

			// how many do we sell per month
			nr_sold_param := action.params.get_default('nr_sold', '')!
			// nr_months_param := action.params.get_int_default('nr_months', 60)!

			mut revenue_setup := m.sheet.row_new(
				name: '${name}_recurring_rev_per_item_setup'
				growth: revenue_setup_param
				tags: 'rev name:${name}'
				descr: 'Revenue for 1 item setup.'
				aggregatetype: .avg
			)!
			mut revenue_monthly := m.sheet.row_new(
				name: '${name}_recurring_rev_per_item_month'
				growth: revenue_monthly_param
				tags: 'rev name:${name}'
				descr: 'Revenue for 1 item per month.'
				aggregatetype: .avg
			)!

			mut nr_sold := m.sheet.row_new(
				name: '${name}_recurring_nr_sold_per_month'
				growth: nr_sold_param
				tags: 'rev  name:${name}'
				descr: 'How many of the items are being sold per month.'
				aggregatetype: .avg
			)!

			mut revenue_setup_total := revenue_setup.action(
				name: '${name}_recurring_rev_setup_aggregated'
				rows: [nr_sold]
				action: .multiply
				tags: 'rev name:${name}'
				delaymonths: revenue_setup_delay_param
				descr: 'What is revenue setup for all items.'
				aggregatetype: .sum
			)!

			// don't remember the next one for printing
			mut revenue_month_total := revenue_monthly.action(
				name: '${name}_recurring_rev_month_aggregated'
				rows: [nr_sold]
				action: .multiply
				delaymonths: revenue_monthly_delay_param
				descr: 'What is revenue monthly for all items.'
				aggregatetype: .sum
			)!

			// mut revenue_month_total_recurring := revenue_month_total_nonrecurring.recurring(
			// 	name: '${name}_recurring_rev_month_aggregated'
			// 	tags: 'rev name:${name}'
			// 	descr: 'What is recurring revenue monthly for all items.'
			// 	aggregatetype: .sum
			// )!

			mut revenue_total := m.sheet.row_new(
				name: '${name}_recurring_rev_total'
				tags: 'rev revtotal name:${name}'
				growth: '1:0.0' // init as 0
				descr: 'What is total revenue for this service/product.'
			)!
			revenue_total.action(
				rows: [revenue_setup_total, revenue_month_total]
				action: .add
			)!

			// NOW WORK WITH COGS

			mut cogs_setup := m.sheet.row_new(
				name: '${name}_cogs_setup'
				growth: cogs_setup_param
				tags: 'cogs name:${name}'
				descr: 'COGS for 1 item setup.'
				aggregatetype: .avg
			)!
			cogs_setup.action(action: .reverse)!
			mut cogs_monthly := m.sheet.row_new(
				name: '${name}_cogs_month_'
				growth: cogs_monthly_param
				tags: 'cogs name:${name}'
				descr: 'COGS for 1 item per month.'
				aggregatetype: .avg
			)!
			cogs_monthly.action(action: .reverse)!

			mut cogs_setup_total := cogs_setup.action(
				name: '${name}_cogs_setup_total'
				rows: [nr_sold]
				action: .multiply
				tags: 'cogs name:${name}'
				descr: 'What is cogs setup for all items.'
				aggregatetype: .sum
			)!
			mut cogs_month_total_nonrecurring := cogs_monthly.action(
				name: '${name}_cogs_month_total_temp_nonrecurring'
				rows: [nr_sold]
				action: .multiply
				descr: 'What is cogs monthly for all items.'
				aggregatetype: .sum
			)!
			mut cogs_month_total := cogs_month_total_nonrecurring.recurring(
				name: '${name}_recurring_cogs_month_aggregated'
				tags: 'cogs name:${name}'
				descr: 'What is recurring cogs monthly for all items.'
				aggregatetype: .sum
			)!

			// the cogs as resulf from perc on revenue
			mut cogs_setup_perc := m.sheet.row_new(
				name: '${name}_cogs_setup_perc'
				growth: cogs_setup_perc_param
				tags: 'name:${name} cogs'
				descr: 'Percentage of cogs'
				aggregatetype: .avg
			)!
			mut cogs_monthly_perc := m.sheet.row_new(
				name: '${name}_cogs_monthly_perc'
				growth: cogs_monthly_perc_param
				tags: 'name:${name} cogs'
				descr: 'Percentage of cogs'
				aggregatetype: .avg
			)!
			mut cogs_setup_from_perc := revenue_setup_total.action(
				name: '${name}_cogs_setup_from_perc'
				rows: [cogs_setup_perc]
				action: .multiply
				tags: 'cogs name:${name}'
				descr: 'What is cogs as percent of setup.'
				aggregatetype: .sum
			)!
			cogs_setup_from_perc.action(action: .reverse)!
			mut cogs_monthly_from_perc := revenue_month_total.action(
				name: '${name}_cogs_monthly_from_perc'
				rows: [cogs_monthly_perc]
				action: .multiply
				tags: 'cogs name:${name}'
				descr: 'What is cogs as percent of monthly.'
				aggregatetype: .sum
			)!
			cogs_monthly_from_perc.action(action: .reverse)!

			mut cogs_total := m.sheet.row_new(
				name: '${name}_cogs_total'
				tags: 'cogs total name:${name}'
				growth: '1:0.0' // init as 0
				descr: 'What is total cogs for this service/product.'
			)!
			cogs_total.action(
				rows: [cogs_setup_total, cogs_month_total, cogs_setup_from_perc,
					cogs_monthly_from_perc]
				action: .add
			)!

			mut margin_total := revenue_total.action(
				action: .add
				rows: [cogs_total]
				name: '${name}_margin_total'
				tags: 'margin margintotal name:${name}'
				descr: 'Total margin for product.'
			)!
		}
	}
	m.sheet.group2row(
		name: 'revenue_total'
		include: ['revtotal']
		tags: 'revtotal2'
		descr: 'total revenue.'
	)!
	m.sheet.group2row(
		name: 'margin_total'
		include: ['margintotal']
		tags: 'pl'
		descr: 'total margin.'
	)!
}
