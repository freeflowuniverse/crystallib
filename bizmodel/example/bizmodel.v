module main

import os
import freeflowuniverse.crystallib.bizmodel
import freeflowuniverse.crystallib.spreadsheet
import cli { Command, Flag }

const testpath = os.dir(@FILE) + '/data'

fn cli_docgen(cmd Command) ! {
	config := docgen.DocGenConfig{
		source: cmd.args[0]
	}
	doc := docgen.docgen(config) or { panic('Failed to generate OpenRPC Document.\n${err}') }
	target := cmd.flags.get_string('output_path') or {
		panic('Failed to get `output_path` flag: ${err}')
	}
	doc_str := doc.encode()!

	mut path_ := pathlib.get(target)
	if !path_.exists() {
		return error('Provided target`${target}` does not exist.')
	}
	mut target_path := path_.path + '/openrpc.json'
	if target == '.' {
		target_path = os.getwd() + '/openrpc.json'
	}


	mut m := bizmodel.new(path: testpath)!
	println('')
	println(m.sheet.wiki(includefilter: ['funding'], name: 'FUNDING')!)
	println(m.sheet.wiki(includefilter: ['rev'], name: 'revenue')!)
	println(m.sheet.wiki(includefilter: ['revtotal'], name: 'revenue total')!)
	println(m.sheet.wiki(includefilter: ['revtotal2'], title_disable: true)!)
	println(m.sheet.wiki(includefilter: ['cogs'], name: 'cogs')!)
	println(m.sheet.wiki(includefilter: ['margin'], name: 'margin')!)
	println(m.sheet.wiki(includefilter: ['hrnr'], name: 'HR Teams')!)
	println(m.sheet.wiki(includefilter: ['hrcost'], name: 'HR Cost')!)
	println(m.sheet.wiki(includefilter: ['ocost'], name: 'COSTS')!)
	println(m.sheet.wiki(includefilter: ['pl'], name: 'P&L Overview')!)

	m.sheet.group2row(
		name: 'company_result'
		include: ['pl']
		tags: 'result'
		descr: 'Net Company Result.'
	)!

	println(m.sheet.wiki(includefilter: ['result'], name: 'Net Company Result.',period_months:3)!)

	mut company_result:=m.sheet.row_get("company_result")!	
	mut cashflow:=company_result.recurring(
		name: 'Cashflow'
		tags: 'cashflow'
		descr: 'Cashflow of company.'	
	)!

	// println(cashflow)

	println(m.sheet.wiki(includefilter: ['cashflow'], name: 'cashflow_aggregated',period_months:3)!)

	cashflow_min:=spreadsheet.float_repr(cashflow.min(),.number)

	println("\nThe lowest cash level over the years: ${cashflow_min}\n")

}

fn main() {
	do() or { panic(err) }
}
