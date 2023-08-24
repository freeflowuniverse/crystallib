module bizmodel

import freeflowuniverse.crystallib.spreadsheet
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.baobab.actions
import freeflowuniverse.crystallib.currency

pub struct BizModel {
pub mut:
	sheet  spreadsheet.Sheet
	params BizModelArgs
	currencies currency.Currencies
}

pub struct BizModelArgs {
pub mut:
	name string
	path string
}

pub fn new(args BizModelArgs) !BizModel {
	mut cs:=currency.new()
	mut sh := spreadsheet.sheet_new(currencies:cs)!
	mut m := BizModel{
		sheet: sh
		params: BizModelArgs{
			path: args.path
			name: texttools.name_fix(args.name)
		}
		currencies:cs
	}

	m.actions()!

	return m
}

pub fn (mut m BizModel) actions() ! {
	println("ACTIONS")
	ap := actions.new(path: m.params.path, defaultcircle: 'bizmodel_${m.params.name}')!
	m.revenue_actions(ap)!
	m.hr_actions(ap)!
	m.funding_actions(ap)!
	m.overhead_actions(ap)!
}
