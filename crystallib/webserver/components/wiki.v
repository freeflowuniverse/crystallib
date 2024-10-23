module components

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.data.markdownparser.elements
import veb
import os

pub struct Wiki {
pub:
	name string
	title string
	directory string // directory of wiki
	static_url string
	summary_path string
	content_path string
}

pub struct WikiController {
	wiki Wiki
mut:
	view View
}

pub struct Context {
	veb.Context
}

pub fn new_wiki_controller(wiki Wiki) &WikiController {
	return &WikiController {
		wiki: wiki
		view: View{
			layout: WikiLayout {}
		}
	}
}

pub fn (mut app WikiController) index(mut ctx Context) veb.Result {
	// mut file := pathlib.get_file(path: os.join_path(app.wiki.directory, path)) or {panic(err)}
	// if file.extension() == 'md' {
	// 	md := markdownparser.new(content: file.read() or {panic(err)}) or {panic(err)}
	// 	app.view.layout.main = Markdown{md}
	// }
	return ctx.html('app.view.html()')
}

['/...path']
pub fn (mut app WikiController) path(mut ctx Context, path string) veb.Result {
	mut file := pathlib.get_file(path: os.join_path(app.wiki.directory, path)) or {panic(err)}
	if file.extension() == 'md' {
		md := markdownparser.new(content: file.read() or {panic(err)}) or {panic(err)}
		app.view.layout.main = Markdown{md}
	}
	return ctx.html(app.view.html())
}

pub struct WikiLayout {
pub mut:
	summary string
	main IComponent
	links string
}

pub fn (layout WikiLayout) html() string {
	dollar := '$'
	return $tmpl('./templates/wiki.html')
}

pub fn (wiki Wiki) html(path string) string {
	dollar := '$'
	mut file := pathlib.get_file(path: wiki.summary_path) or {panic(err)}
	summary := file.read() or {panic(err)}

	index_path := wiki.get_index_path(summary) or {
		panic(err)
	}

	mut index_file := pathlib.get_file(path: index_path) or {
		panic(err)
	}
	index := index_file.read() or {panic(err)}
	index_md := markdownparser.new(content: index) or {panic(err)}
	index2 := index_md.html() or {panic(err)}

	return $tmpl('./templates/wiki_copy.html')
}

fn (wiki Wiki) get_index_path(summary string) !string {
	summary_doc := markdownparser.new(content: summary) or {panic(err)}
	index_url := (summary_doc.children[1].children[0].children[0].children[0] as elements.Link).url
	return '${wiki.content_path}/${index_url}'
}