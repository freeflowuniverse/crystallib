#!/usr/bin/env -S v -w -cg -enable-globals run


import os
import freeflowuniverse.crystallib.biz.bizmodel
// import freeflowuniverse.crystallib.data.knowledgetree
// import freeflowuniverse.crystallib.biz.spreadsheet
// import cli { Command }

const wikipath = os.dir(@FILE) + '/wiki'

// mut c := context.new()!

mut book := bizmodel.new(
	name: 'example'
	mdbook_name: 'biz_book'
	mdbook_path: wikipath
	mdbook_dest: '/tmp/dest'
	path: wikipath
)!

book.load()! // will generate and open

//// TODO: Kristof check if we have everything then remove

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
