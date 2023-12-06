module bizmodel

import freeflowuniverse.crystallib.biz.spreadsheet
import freeflowuniverse.crystallib.baobab.smartid
// import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.doctree
import freeflowuniverse.crystallib.data.actionparser
import os

__global (
	bizmodels shared map[string]BizModel
)

pub struct BizModel {
pub mut:
	sheet     spreadsheet.Sheet
	params    BizModelArgs
	employees map[string]&Employee
	// currencies currency.Currencies
}

@[params]
pub struct BizModelArgs {
pub mut:
	name        string = 'default' // name of bizmodel
	path        string
	git_url     string
	git_reset   bool
	git_root    string
	git_pull    bool
	mdbook_name string // if empty will be same as name of bizmodel
	mdbook_path string
	mdbook_dest string // if empty is /tmp/mdbooks/$name
	cid         smartid.CID
}

pub fn new(args_ BizModelArgs) !doctree.MDBook {
	mut args := args_

	// mut cs := currency.new()
	mut sh := spreadsheet.sheet_new()!
	mut bm := BizModel{
		sheet: sh
		params: args
		// currencies: cs
	}
	bm.load()!

	lock bizmodels {
		bizmodels[args.name] = bm
	}

	if args.name == '' {
		return error('bizmodel needs to have a name')
	}

	args.name = texttools.name_fix(args.name)

	if args.mdbook_name == '' {
		args.mdbook_name = args.name
	}

	tree_name := 'bizmodel_${args.name}'
	mut tree := doctree.new(name: tree_name)!

	mp := macroprocessor_new(args_.name)
	tree.macroprocessor_add(mp)!

	if args.git_url.len > 0 {
		args.path = gittools.code_get(
			coderoot: args.git_root
			url: args.git_url
			pull: args.git_pull
			reset: args.git_reset
			reload: false
		)!
	}

	tree.scan(
		name: 'crystal_manual'
		git_url: 'https://github.com/freeflowuniverse/crystallib/tree/development/manual/biz' // TODO: needs to be come development
		heal: false
		cid: args.cid
	)!

	tree.scan(
		name: tree_name
		path: args.path
		heal: true
		cid: args.cid
	)!

	mut book := doctree.book_generate(
		path: args.mdbook_path
		name: args.mdbook_name
		tree: tree
		dest: args.mdbook_dest
	)!

	return *book
}

pub fn (mut m BizModel) load() ! {
	println('ACTIONS LOAD ${m.params.name}')

	// m.replace_smart_ids()!
	mut tree := doctree.new(name: 'bizmodel_${m.params.name}')!
	tree.scan( path: m.params.path)!
	mut actions_collections := actionparser.ActionsCollection{}
	for collection in tree.collections.values(){
		for page in collection.pages.values(){
			if d := page.doc{
				actions_collections.actions << d.actions()
			}
		}
	}

	// ap := actionparser.parse(path: m.params.path, defaultcircle: 'bizmodel_${m.params.name}')!
	m.revenue_actions(actions_collections)!
	m.hr_actions(actions_collections)!
	m.funding_actions(actions_collections)!
	m.overhead_actions(actions_collections)!

	// tr.scan(
	// 	path: wikipath
	// 	heal: false
	// )!

	// QUESTION: why was this here?
	// m.sheet.group2row(
	// 	name: 'company_result'
	// 	include: ['pl']
	// 	tags: 'netresult'
	// 	descr: 'Net Company Result.'
	// )!

	// mut company_result := m.sheet.row_get('company_result')!
	// mut cashflow := company_result.recurring(
	// 	name: 'Cashflow'
	// 	tags: 'cashflow'
	// 	descr: 'Cashflow of company.'
	// )!
}
