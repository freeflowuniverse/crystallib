module bizmodel

import freeflowuniverse.crystallib.knowledgetree
import freeflowuniverse.crystallib.baobab.actions
import freeflowuniverse.crystallib.spreadsheet

pub struct MacroProcessorBizmodel {
	bizmodel_name string // name of bizmodel the macro will use for processing
}

pub fn macroprocessor_new(bizmodel_name string) MacroProcessorBizmodel {
	return MacroProcessorBizmodel{bizmodel_name}
}

pub fn (processor MacroProcessorBizmodel) process(code string) !knowledgetree.MacroResult {
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

			rlock bizmodels {
				mut model := bizmodels[processor.bizmodel_name]
				r.result = model.sheet.wiki(args) or { panic(err) }
			}
			// r.result = m.sheet.wiki(data)
			// r.result = mp.spawner.rpc(mut tname: 'bizmodel', method: 'WIKI', val: json.encode(args))!
			r.result += '<BR>'

			// TODO: use the global spreadsheet to get the results

			return r
		}

		size := p.get_default('size', '')!

		supported_actions := ['graph_pie_row', 'graph_line_row', 'graph_bar_row', 'graph_title_row']

		if action.name in supported_actions {
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
				println(action)
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

			mut model := BizModel{}
			rlock bizmodels {
				model = bizmodels[processor.bizmodel_name]
			}

			match action.name {
				'graph_title_row' {
					r.result = model.sheet.wiki_title_chart(args)
				}
				'graph_line_row' {
					r.result = model.sheet.wiki_line_chart([args]) or { panic(err) }
				}
				'graph_bar_row' {
					r.result = model.sheet.wiki_bar_chart(args) or { panic(err) }
				}
				'graph_pie_row' {
					r.result = model.sheet.wiki_pie_chart(args) or { panic(err) }
				}
				'wiki_row_overview' {
					r.result = model.sheet.wiki_row_overview(args) or { panic(err) }
				}				
				else {
					panic('unexpected action name ${action.name}')
				}
			}

			// r.result = mp.spawner.rpc(mut
			// 	tname: 'bizmodel'
			// 	method: chart_methodname
			// 	val: json.encode(args)
			// )!
			r.result += '\n'
			return r
		} else {
			logger.warn('action ${action.name} isnt supported yet')
		}
	}
	return r
}
