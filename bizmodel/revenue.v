module bizmodel

import freeflowuniverse.crystallib.baobab.actionsparser
import freeflowuniverse.crystallib.texttools

fn (mut m BizModel) revenue_actions(actions actionsparser.ActionsParser) ! {
	mut actions2 := actions.filtersort(actor: 'revenue')!
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
			// - revenue_growth: how does cost grow over time e.g. 1:10000USD,20:20000USD
			// - cogs_delay_month: how many months delay on cost of goods, default is 0 months
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

			// cost of goods
			cogs_delay_month := action.params.get_float_default('cogs_delay_month', 3.0)!
			cogs_perc := action.params.get_percentage_default('cogs_perc', '0%')!

			mut revenue_item := m.sheet.row_new(
				name: 'rev_item_${name}'
				growth: revenue_item_param
				tags: 'cat:rev name:${name}'
				descr: 'What is revenue for 1 item.'
				aggregatetype: .avg
			)!
			mut revenue_nr := m.sheet.row_new(
				name: 'revenue_nr_${name}'
				growth: revenue_nr_param
				tags: 'cat:rev  name:${name}'
				descr: 'How many of the items are being sold per month.'
			)!

			// multiply rev item with rev nr to get to total
			mut revenue_item_total := revenue_item.action(
				name: 'rev_item_total_${name}'
				rows: [revenue_nr]
				action: .multiply
				tags: 'cat:rev name:${name}'
				descr: 'What is revenue for all items.'
				aggregatetype: .sum
			)!

			mut revenue_total := m.sheet.row_new(
				name: 'revenue_total_${name}'
				tags: 'cat:rev total name:${name}'
				growth: '1:0.0'
				descr: 'What is sum of recurring, oneoff and growth, is total revenue for this service/product.'
			)!

			mut revenue_time := m.sheet.row_new(
				name: 'rev_time_${name}'
				growth: revenue_time_param
				tags: 'cat:rev  name:${name}'
				descr: 'Onetime revenues.'
				extrapolate: false
			)!
			mut revenue_growth := m.sheet.row_new(
				name: 'revenue_growth_${name}'
				growth: revenue_growth_param
				tags: 'cat:rev name:${name}'
				descr: 'What is other revenue growth, interpolated.'
			)!
			revenue_total.action(
				action: .sum
				rows: [revenue_growth, revenue_time, revenue_item_total]
			)!

			cogs_total := revenue_total.action(
				name: 'cogs_total_${name}'
				action: .multiply
				rows: [cogs_perc]
				delay: cogs_delay_month
				tags: 'cat:cogs total name:${name}'
				descr: 'Cost of goods.'
			)!
		} else if action.name == 'recurring_define' {
			// - name, e.g. for a specific project
			// - descr, description of the revenue line item
			// - revenue_setup, revenue for 1 item '1000usd'
			// - revenue_monthly, revenue per month for 1 item
			// - revenue_monthly_delay, how many months before monthly revenue starts
			// - cogs_setup, cost of good for 1 item at setup
			// - cogs_setup_delay, in int, is expressed in months
			// - cogs_monthly, cost of goods for the monthly per 1 item
			// - cogs_monthly_delay, in int, is for months
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
			mut revenue_setup_param := action.params.get_default('revenue_setup', '')!
			mut revenue_monthly_param := action.params.get_default('revenue_monthly',
				'')!
			revenue_monthly_delay_param := action.params.get_float_default('revenue_monthly_delay',
				0.0)!

			// cogs
			mut cogs_setup := action.params.get_default('cogs_setup', '')!
			cogs_setup_delay := action.params.get_float_default('cogs_setup_delay', 0.0)!
			mut cogs_monthly := action.params.get_default('cogs_monthly', '')!
			cogs_monthly_delay := action.params.get_float_default('cogs_monthly_delay',
				0.0)!

			// how many do we sell per month
			mut nr_sold := action.params.get_default('nr_sold', '')!
			nr_months := action.params.get_int_default('nr_months', 60)!

			mut revenue_setup := m.sheet.row_new(
				name: 'rev_setup_${name}'
				growth: revenue_setup_param
				tags: 'cat:rev name:${name}'
				descr: 'Revenue for 1 item setup.'
				aggregatetype: .avg
			)!
			mut revenue_monthly := m.sheet.row_new(
				name: 'rev_month_${name}'
				growth: revenue_monthly_param
				tags: 'cat:rev name:${name}'
				descr: 'Revenue for 1 item per month.'
				aggregatetype: .avg
			)!

			// mut cogs_setup:=m.sheet.row_new(name: "cogs_setup_$name", growth:cogs_setup, tags:"cat:cogs name:$name",
			// 			descr:'COGS for 1 item setup.',aggregatetype:.avg)!
			// mut cogs_monthly:=m.sheet.row_new(name: "cogs_month_$name", growth:cogs_monthly, tags:"cat:cogs name:$name",
			// 			descr:'COGS for 1 item per month.',aggregatetype:.avg)!

			// mut nr_sold:=m.sheet.row_new(name: "nr_sold_per_month_$name", growth:nr_sold, tags:"cat:rev  name:$name",
			// 			descr:'How many of the items are being sold per month.')!

			// mut revenue_item_total:=revenue_item.action(name: "rev_item_total_$name",
			// 			rows: [revenue_nr], action:.multiply,
			// 			tags:"cat:rev name:$name",
			// 			descr:'What is revenue for all items.',aggregatetype:.sum)!

			panic('implement')

			mut revenue_total := m.sheet.row_new(
				name: 'revenue_total_${name}'
				tags: 'cat:rev total name:${name}'
				growth: '1:0.0'
				descr: 'What is sum of recurring, oneoff and growth, is total revenue for this service/product.'
			)!

			cogs_total := revenue_total.action(
				name: 'cogs_total_${name}'
				action: .multiply
				rows: [cogs_perc]
				delay: cogs_delay_month
				tags: 'cat:cogs total name:${name}'
				descr: 'Cost of goods.'
			)!
		}
	}
}
