module bizmodel

import freeflowuniverse.crystallib.knowledgetree
import freeflowuniverse.crystallib.baobab.actions
import freeflowuniverse.crystallib.spreadsheet
import freeflowuniverse.crystallib.markdowndocs

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

		if action.name == 'employee_wiki' {
			mut model := BizModel{}
			rlock bizmodels {
				model = bizmodels[processor.bizmodel_name]
			}
			id := p.get_default('id', '')!
			if id !in model.employees {
				return error('employee with id <${id}> not found')
			}
			employee := model.employees[id]

			employee_table := markdowndocs.Table{
				header: ['Key', 'Value']
				rows: [
					['cost', employee.cost],
					['department', employee.department],
					['indexation', '${employee.indexation}'],
				]
				alignments: [.left, .left]
			}.wiki()
			r.result = $tmpl('./templates/employee.md')
			return r
		}

		supported_actions := ['sheet_wiki','graph_pie_row', 'graph_line_row', 'graph_bar_row', 'graph_title_row',
			'wiki_row_overview', 'employee_wiki', 'employees_wiki']

		if action.name in supported_actions {
			namefilter:=get_list("namefilter")!
			includefilter:=get_list("includefilter")!
			excludefilter:=get_list("excludefilter")!
			size := p.get_default('size', '')!
			title_sub := p.get_default('title_sub', '')!
			title := p.get_default('title', '')!
			unit := p.get_default('unit', 'normal')!
			unit_e = match unit {
				'thousand' { .thousand }
				'million' { .million }
				'billion' { .billion }
				else { .normal }
			}
			period_type := p.get_default('period_type', 'year')!
			if period_type !in ['year', 'month', 'quarter'] {
				return error('period type needs to be in year,month,quarter')
			}
			period_type_e = match period_type {
				'year' { .year }
				'month' { .month }
				'quarter' { .quarter }
				else { .error }
			}
			if period_type_e == .error {
				return error('period type needs to be in year,month,quarter')
			}

			aggregate := p.get_default_false('aggregate')!
			rowname_show := p.get_default_true('rowname_show')!

			// namefilter    []string // only include the exact names as secified for the rows
			// includefilter   []string // to use with params filter e.g. ['location:belgium_*'] //would match all words starting with belgium
			// excludefilter   []string
			// period_type   PeriodType       // year, month, quarter
			// aggregate     bool = true // if more than 1 row matches should we aggregate or not
			// aggregatetype RowAggregateType = .sum // important if used with include/exclude, because then we group
			// unit          UnitType
			// title         string
			// title_sub     string
			// size          string
			// rowname_show       bool = true  //show the name of the row

			args := spreadsheet.RowGetArgs{
				namefilter:namefilter
				includefilter:includefilter
				excludefilter:excludefilter
				period_type: period_type_e
				unit: unit_e
				title_sub: title_sub
				title: title
				size: size
				rowname_show: rowname_show
			}

			mut model := BizModel{}
			rlock bizmodels {
				model = bizmodels[processor.bizmodel_name]
			}

			match action.name {
				'graph_title_row' {
					r.result = model.sheet.wiki(args) or { panic(err) }
				}
				'graph_title_row' {
					r.result = model.sheet.wiki_title_chart(args)
				}
				'graph_line_row' {
					r.result = model.sheet.wiki_line_chart([args])!
				}
				'graph_bar_row' {
					r.result = model.sheet.wiki_bar_chart(args)!
				}
				'graph_pie_row' {
					r.result = model.sheet.wiki_pie_chart(args)!
				}
				'wiki_row_overview' {
					r.result = model.sheet.wiki_row_overview(args)!
				}
				else {
					return error('unexpected action name ${action.name}')
				}
			}

			r.result += '\n<BR>'
			return r
		} else {
			logger.warn('action ${action.name} isnt supported yet')
		}
	}
	return r
}
