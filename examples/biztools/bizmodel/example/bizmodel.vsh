#!/usr/bin/env -S v -gc none -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

import freeflowuniverse.crystallib.core.playcmds
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.webtools.mdbook
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.data.doctree
import os

//import freeflowuniverse.crystallib.biz.bizmodel
// import freeflowuniverse.crystallib.data.knowledgetree
// import freeflowuniverse.crystallib.biz.spreadsheet
// import cli { Command }

const wikipath = os.dir(@FILE) + '/wiki'
const summarypath = os.dir(@FILE) + '/wiki/summary.md'

//just run the doctree & mdbook and it should 

//load the doctree, these are all collections
mut tree := doctree.new(name: 'main')!
tree.scan(path:wikipath)!	
tree.export(dest: "/tmp/buildroot/tree", reset: true)!

mut mdbooks := mdbook.get()!
mdbooks.generate(
	doctree_path: "/tmp/buildroot/tree"
	name:         "bizmodelexample"
	title:        "bizmodelexample"
	summary_path:  summarypath
	build_path:   "/tmp/buildroot/html"
)!

mdbook.book_open("bizmodelexample")!

// mut c := context.new()!

// mut bizmodel := bizmodel.new(
// 	name: 'example'
// 	mdbook_name: 'biz_book'
// 	mdbook_path: wikipath
// 	mdbook_dest: '/tmp/dest'
// 	path: wikipath
// )!

// bizmodel.book_generate(open:true)! // will generate and open

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
