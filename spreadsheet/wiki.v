module spreadsheet

import freeflowuniverse.crystallib.texttools

[params]
pub struct WikiArgs {
pub mut:
	name          string
	namefilter    []string // only include the exact names as secified for the rows
	includefilter []string // matches for the tags
	excludefilter []string // matches for the tags
	period_months int = 12 // 3 for quarter, 12 for year, 1 for all months
	description   string
	title         string
	rowname       bool = true
}

// format a sheet properly in wiki format
pub fn (mut s Sheet) wiki(args_ WikiArgs) !string {
	mut args := args_
	if args.name == '' {
		args.name = s.name
	}

	argssmaller := ToYearQuarterArgs{
		name: args.name
		includefilter: args.includefilter
		excludefilter: args.excludefilter
		namefilter: args.namefilter
		period_months: args.period_months
	}
	mut sheet := s.tosmaller(argssmaller)! // this will do the filtering and if needed make smaller

	mut out := ''
	if args.title.len > 0 {
		out = '## ${args.title}\n\n'
	}
	if args.description != '' {
		out += args.description + '\n\n'
	}

	mut colmax := []int{}
	for x in 0 .. sheet.nrcol {
		colmaxval := sheet.cells_width(x)!
		colmax << colmaxval
	}

	header := sheet.header()!

	// get the width of name and optionally description
	names_width := sheet.names_width()

	mut header_wiki_items := []string{}
	mut header_wiki_items2 := []string{}
	if args.rowname && names_width[0] > 0 {
		header_wiki_items << texttools.expand('|', names_width[0] + 1, ' ')
		header_wiki_items2 << texttools.expand('|', names_width[0] + 1, '-')
	}
	for x in 0 .. sheet.nrcol {
		colmaxval := colmax[x]
		headername := header[x]
		item := texttools.expand(headername, colmaxval, ' ')
		header_wiki_items << '|${item}'
		item2 := texttools.expand('', colmaxval, '-')
		header_wiki_items2 << '|${item2}'
	}
	header_wiki_items << '|'
	header_wiki_items2 << '|'
	header_wiki := header_wiki_items.join('')
	header_wiki2 := header_wiki_items2.join('')

	out += header_wiki + '\n'
	out += header_wiki2 + '\n'

	for _, mut row in sheet.rows {
		mut wiki_items := []string{}
		if args.rowname && names_width[0] > 0 {
			wiki_items << texttools.expand('|${row.name}', names_width[0] + 1, ' ')
		}
		for x in 0 .. sheet.nrcol {
			colmaxval := colmax[x]
			val := row.cells[x].str()
			item := texttools.expand(val, colmaxval, ' ')
			wiki_items << '|${item}'
		}
		wiki_items << '|'
		wiki2 := wiki_items.join('')
		out += wiki2 + '\n'
	}

	return out
}
