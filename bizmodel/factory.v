module bizmodel

import freeflowuniverse.crystallib.calc
import freeflowuniverse.crystallib.baobab.actionsparser

pub struct BizModel {
pub mut:
	sheet  calc.Sheet
	params BizModelArgs
}

pub struct BizModelNewArgs {
	path string
}

pub fn new(args BizModelNewArgs) !BizModel {
	mut sh := calc.sheet_new()!
	mut m := BizModel{
		sheet: sh
		params: BizModelArgs{
			data_path: args.path
		}
	}

	m.actions()!

	return m
}

pub fn (mut m BizModel) actions() ! {
	ap := actionsparser.new(path: m.params.data_path, defaultbook: 'aaa')!
	m.hr_actions(ap)!
	m.revenue_actions(ap)!
}
