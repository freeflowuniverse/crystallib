module bizmodel

import freeflowuniverse.crystallib.spreadsheet
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.knowledgetree
import freeflowuniverse.crystallib.baobab.actions
// import freeflowuniverse.crystallib.baobab.hero
// import freeflowuniverse.crystallib.baobab.context
import freeflowuniverse.crystallib.osal.downloader
import freeflowuniverse.crystallib.currencies

pub struct BizModel {
pub mut:
	sheet   spreadsheet.Sheet
	params  BizModelArgs
	book    ?knowledgetree.MDBook
}

[params]
pub struct BizModelArgs {
pub mut:
	name        string
	path        string
	git_url     string
	git_reset   bool
	git_root    string
	git_pull    bool
	git_branch  string
	mdbook_name string // if empty will be same as name of bizmodel
	mdbook_path string // if empty is /tmp/mdbooks/$name
}

pub fn new(args_ BizModelArgs) !BizModel {
	mut args := args_
	mut sh := spreadsheet.sheet_new(currencies: cs)!

	if args.name == '' {
		args.name = texttools.name_fix(args.name)
	}

	if args.mdbook_name == '' {
		args.mdbook_name = args.name
	}

	mut bm := BizModel{
		sheet: sh
		params: BizModelArgs{
			path: args.path
			url: args.url
			name: args.name
		}
		context: args.context
		currencies: currencies.new() or { panic(err) }
	}

	bm.load()!

	mut tree := args.context.knowledgetree('bizmodel_${args.name}')!

	// mut gs := c.gitstructure('default')!
	// if args.git_root.len > 0 {
	// 	c.gitstructure_new(name: 'bizmodel_${args.name}', root: args.git_root, light: true)
	// }

	// if args.git_url.len > 0 {
	// 	gs = c.gitstructure()!
	// 	mut gr := gs.repo_get_from_url(
	// 		url: args.git_url
	// 		branch: args.git_branch
	// 		pull: args.git_pull
	// 		reset: args.git_reset
	// 	)!
	// 	args.path = gr.path_content_get()
	// }

	// tree.scan(path: args.path)!

	// mut book := knowledgetree.book_create(
	// 	path: '${wikipath}'
	// 	name: args.mdbook_name
	// 	tree: tree
	// 	dest: args.mdbook_path
	// )!

	return book
}

pub fn (mut m BizModel) load() ! {
	println('ACTIONS LOAD ${m.params.name}')
	ap := actions.new(path: m.params.path, defaultcircle: 'bizmodel_${m.params.name}')!
	m.revenue_actions(ap)!
	m.hr_actions(ap)!
	m.funding_actions(ap)!
	m.overhead_actions(ap)!

	tr.scan(
		path: wikipath
		heal: false
	)!

	m.sheet.group2row(
		name: 'company_result'
		include: ['pl']
		tags: 'netresult'
		descr: 'Net Company Result.'
	)!

	mut company_result := m.sheet.row_get('company_result')!
	mut cashflow := company_result.recurring(
		name: 'Cashflow'
		tags: 'cashflow'
		descr: 'Cashflow of company.'
	)!
}
