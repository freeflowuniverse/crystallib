module bizmodel

import freeflowuniverse.crystallib.baobab.spawner
import freeflowuniverse.crystallib.knowledgetree
import freeflowuniverse.crystallib.baobab.actions
import freeflowuniverse.crystallib.spreadsheet
import json

pub struct MacroProcessorBizmodel {
pub mut:
	spawner &spawner.Spawner
}

pub fn macroprocessor_new(mut s spawner.Spawner) MacroProcessorBizmodel {
	return MacroProcessorBizmodel{
		spawner: s
	}
}

pub fn (mut mp MacroProcessorBizmodel) process(code string) !knowledgetree.MacroResult {
	mut r := knowledgetree.MacroResult{
		state: .stop
	}
	ap := actions.new(text: code)!
	mut actions2 := ap.filtersort(actor: 'bizmodel')!
	for action in actions2 {
		p := action.params
		mut period_type_e := spreadsheet.PeriodType.error // year, month, quarter
		mut unit_e := spreadsheet.UnitType.normal
		if action.name == 'sheet_wiki' {
			args := spreadsheet.WikiArgs{
				name: p.get_default('name', '')!
				namefilter: p.get_list_default('namefilter', [])!
				includefilter: p.get_list_default('includefilter', [])!
				excludefilter: p.get_list_default('excludefilter', [])!
				period_months: p.get_int_default('period_months', 12)!
				title: p.get_default('title', '')!
				rowname: p.get_default_true('rowname')
			}
			r.result = mp.spawner.rpc(mut tname: 'bizmodel', method: 'WIKI', val: json.encode(args))!
			// r.result+="<BR>"
			return r
		}

		chart_methodname := match action.name {
			'graph_bar_row' { 'BARCHART1' }
			'graph_pie_row' { 'PIECHART1' }
			else { '' }
		}

		size := p.get_default('size', '')!

		if chart_methodname.len > 0 {
			rowname := p.get_default('rowname', '')!
			unit := p.get_default('unit', 'normal')!
			unit_e = match unit {
				'thousand' { .thousand }
				'million' { .million }
				'billion' { .billion }
				else { .normal }
			}
			period_type := p.get_default('period_type', 'year')!

			period_type_e = match period_type {
				'year' { .year }
				'month' { .month }
				'quarter' { .quarter }
				else { .error }
			}
			if period_type_e == .error {
				return error('period type needs to be in year,month,quarter')
			}
			if rowname == '' {
				return error('specify the rowname please')
			}
			if period_type !in ['year', 'month', 'quarter'] {
				return error('period type needs to be in year,month,quarter')
			}

			title_sub := p.get_default('title_sub', '')!
			title := p.get_default('title', '')!

			args := spreadsheet.RowGetArgs{
				rowname: rowname
				period_type: period_type_e
				unit: unit_e
				title_sub: title_sub
				title: title
				size: size
			}
			r.result = mp.spawner.rpc(mut
				tname: 'bizmodel'
				method: chart_methodname
				val: json.encode(args)
			)!
			r.result += '\n'
			return r
		}
	}
	return r
}
