module calc

import freeflowuniverse.crystallib.texttools
import v.embed_file


enum SheetState {
	init
	initdone
	ok
}

[params]
pub struct SheetArgs {
pub mut:
	name          string
	rowsfilter    []string
	tagsfilter    []string
	period_months int = 12 // 3 for quarter, 12 for year, 1 for all months
	description   string
	title         string
	title_disable bool
	rowname       bool = true
	state         SheetState
	embedded_files []embed_file.EmbedFileData // this where we have the templates for exporting a sheet
}

// make sure all initialization has been done e.g. installing mdsheet
fn (mut sh Sheet) init() ! {
	println('embeding files')
	if sh.state == .init {
		// TODOIT: how to embed
		sh.embedded_files << $embed_file('template/theme/css/xspreadsheet.css')
		sh.embedded_files << $embed_file('template/xspreadsheet.js')
		sh.state = .initdone
	}
}

// format a sheet properly in wiki format
pub fn (mut s Sheet) html(args_ SheetArgs) !string {
	mut args := args_
	if args.name == '' {
		args.name = s.name
	}

	// argssmaller := ToYearQuarterArgs{
	// 	name: args.name
	// 	rowsfilter: args.rowsfilter
	// 	tagsfilter: args.tagsfilter
	// 	period_months: args.period_months
	// }
	// mut sheet := s.tosmaller(argssmaller)! // this will do the filtering and if needed make smaller

	if args.title == '' {
		args.title = 'Sheet ${args.name}.'
	}
	mut out := ''
	// TODOIT: how he parse the data from the sheets object

	out += '
		<h1>
			${args.description}
		</h1>
	'
	// TODOIT: how to embed


	s.embedded_files << $embed_file('template/theme/css/xspreadsheet.css')
	s.embedded_files << $embed_file('template/xspreadsheet.js')

	// if !args.title_disable {
	// 	out = '## ${args.title}\n\n'
	// }
	// if args.description != '' {
	// 	out += args.description + '\n\n'
	// }

	// mut colmax := []int{}
	// for x in 0 .. sheet.nrcol {
	// 	colmaxval := sheet.cells_width(x)!
	// 	colmax << colmaxval
	// }

	// header := sheet.header()!

	// // get the width of name and optionally description
	// names_width := sheet.names_width()

	// mut header_wiki_items := []string{}
	// mut header_wiki_items2 := []string{}
	// if args.rowname && names_width[0] > 0 {
	// 	header_wiki_items << texttools.expand('|', names_width[0] + 1, ' ')
	// 	header_wiki_items2 << texttools.expand('|', names_width[0] + 1, '-')
	// }
	// for x in 0 .. sheet.nrcol {
	// 	colmaxval := colmax[x]
	// 	headername := header[x]
	// 	item := texttools.expand(headername, colmaxval, ' ')
	// 	header_wiki_items << '|${item}'
	// 	item2 := texttools.expand('', colmaxval, '-')
	// 	header_wiki_items2 << '|${item2}'
	// }
	// header_wiki_items << '|'
	// header_wiki_items2 << '|'
	// header_wiki := header_wiki_items.join('')
	// header_wiki2 := header_wiki_items2.join('')

	// out += header_wiki + '\n'
	// out += header_wiki2 + '\n'

	// for _, mut row in sheet.rows {
	// 	mut wiki_items := []string{}
	// 	if args.rowname && names_width[0] > 0 {
	// 		wiki_items << texttools.expand('|${row.name}', names_width[0] + 1, ' ')
	// 	}
	// 	for x in 0 .. sheet.nrcol {
	// 		colmaxval := colmax[x]
	// 		val := row.cells[x].str()
	// 		item := texttools.expand(val, colmaxval, ' ')
	// 		wiki_items << '|${item}'
	// 	}
	// 	wiki_items << '|'
	// 	wiki2 := wiki_items.join('')
	// 	out += wiki2 + '\n'
	// }

	return out
}
