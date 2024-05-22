module elements

import freeflowuniverse.crystallib.core.playbook
// import freeflowuniverse.crystallib.data.paramsparser

@[heap]
interface Element {
mut:
	actionpointers(ActionsGetArgs) []&Action
	actions(ActionsGetArgs) []&playbook.Action
	changed   bool
	children []&Element
	children_recursive_(mut []&Element)
	children_recursive() []&Element
	content   string
	content_set(int, string)
	defpointers() []&Def
	delete_last() !
	header_name() !string
	html() !string
	id        int
	id_set(int) int
	markdown() !string
	process() !int
	processed bool
	pug() !string
	last() !&Element
	treeview_(string, mut []string)
	type_name string

	//methods from base_add_methods
	// paragraph_new(mut ?&Doc, string) &Paragraph
	// action_new(mut &Doc, string) &Action
	// table_new(mut &Doc,  string) &Table 
	// header_new(mut &Doc, string) &Header
	// list_new(mut &Doc, string) &List
	// list_item_new(mut  &Doc, string) &ListItem 
	// text_new(mut &Doc, string) &Text 
	// empty_new() &Empty
	// comment_new(mut &Doc, string) &Comment
	// codeblock_new(mut &Doc, string) &Codeblock
	// link_new(mut &Doc, string) &Link
	// html_new(mut &Doc, string) &Html
	// def_new(mut &Doc, string) &Def

}

