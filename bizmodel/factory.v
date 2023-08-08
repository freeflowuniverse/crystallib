module bizmodel

import freeflowuniverse.crystallib.spreadsheet
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.baobab.actions

pub struct BizModel {
pub mut:
	sheet  spreadsheet.Sheet
	params BizModelArgs
}



pub struct BizModelArgs {
pub mut:
	name      string
	path string
}


pub fn new(args BizModelArgs) !BizModel {
	mut sh := spreadsheet.sheet_new()!
	mut m := BizModel{
		sheet: sh
		params: BizModelArgs{
			path: args.path
			name: texttools.name_fix(args.name)
		}
	}

	m.actions()!

	return m
}

pub fn (mut m BizModel) actions() ! {
	ap := actions.new(path: m.params.path, defaultcircle: 'bizmodel_${m.params.name}')!
	m.revenue_actions(ap)!
	m.hr_actions(ap)!
}
