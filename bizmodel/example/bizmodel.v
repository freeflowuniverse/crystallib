module main
import freeflowuniverse.crystallib.baobab.spawner
import os
import freeflowuniverse.crystallib.bizmodel
// import freeflowuniverse.crystallib.spreadsheet
// import cli { Command }

const testpath = os.dir(@FILE) + '/data'



fn do() ! {

	mut s:=spawner.new()
	mut m:=bizmodel.background(mut s,path:testpath)!

	println(m.wiki(includefilter: ['funding'], name: 'FUNDING')!)
	
	// println('')
	// println(m.sheet.wiki(includefilter: ['funding'], name: 'FUNDING')!)
	// println(m.sheet.wiki(includefilter: ['rev'], name: 'revenue')!)
	// println(m.sheet.wiki(includefilter: ['revtotal'], name: 'revenue total')!)
	// println(m.sheet.wiki(includefilter: ['revtotal2'], title_disable: true)!)
	// println(m.sheet.wiki(includefilter: ['cogs'], name: 'cogs')!)
	// println(m.sheet.wiki(includefilter: ['margin'], name: 'margin')!)
	// println(m.sheet.wiki(includefilter: ['hrnr'], name: 'HR Teams')!)
	// println(m.sheet.wiki(includefilter: ['hrcost'], name: 'HR Cost')!)
	// println(m.sheet.wiki(includefilter: ['ocost'], name: 'COSTS')!)
	// println(m.sheet.wiki(includefilter: ['pl'], name: 'P&L Overview')!)

	// m.sheet.group2row(
	// 	name: 'company_result'
	// 	include: ['pl']
	// 	tags: 'result'
	// 	descr: 'Net Company Result.'
	// )!

	// println(m.sheet.wiki(includefilter: ['result'], name: 'Net Company Result.', period_months: 3)!)

	// mut company_result := m.sheet.row_get('company_result')!
	// mut cashflow := company_result.recurring(
	// 	name: 'Cashflow'
	// 	tags: 'cashflow'
	// 	descr: 'Cashflow of company.'
	// )!

	// // println(cashflow)

	// println(m.sheet.wiki(includefilter: ['cashflow'], name: 'cashflow_aggregated', period_months: 3)!)

	// cashflow_min := spreadsheet.float_repr(cashflow.min(), .number)

	// println('\nThe lowest cash level over the years: ${cashflow_min}\n')
}

fn main() {
	do() or { panic(err) }
}
