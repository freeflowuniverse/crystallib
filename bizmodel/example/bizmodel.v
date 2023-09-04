module main

import freeflowuniverse.crystallib.baobab.spawner
import os
import freeflowuniverse.crystallib.bizmodel
import freeflowuniverse.crystallib.knowledgetree
// import freeflowuniverse.crystallib.spreadsheet
// import cli { Command }

const wikipath = os.dir(@FILE) + '/wiki'

fn do() ! {
	mut s := spawner.new()
	mut m := bizmodel.background(mut s, path: wikipath)!

	println(m.wiki(includefilter: ['funding'], name: 'FUNDING')!)

	mut tr := knowledgetree.new(mut &s)!

	mut mp := bizmodel.macroprocessor_new(mut &s)

	tr.macroprocessor_add(mut &mp)!

	tr.scan(path: wikipath, heal: false)!
	mut book := tr.book_new(path: '${wikipath}', name: 'mybook')!
	book.read()! // will generate and open	

	// println('')

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
