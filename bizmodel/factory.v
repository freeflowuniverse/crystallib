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
	data_path string
}


pub fn new(args BizModelArgs) !BizModel {
	mut sh := spreadsheet.sheet_new()!
	mut m := BizModel{
		sheet: sh
		params: BizModelArgs{
			data_path: args.path
			name: textools.name_fix(args.name)
		}
	}

	m.actions()!

	return m
}

pub fn (mut m BizModel) actions() ! {
	ap := actions.new(path: m.params.data_path, defaultcircle: 'bizmodel_${m.params.name}')!
	m.revenue_actions(ap)!
	m.hr_actions(ap)!
}
