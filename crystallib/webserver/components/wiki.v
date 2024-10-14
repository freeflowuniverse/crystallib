module components

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.data.markdownparser.elements

pub struct Wiki {
pub:
	static_url string
	summary_path string
	content_path string
}

pub fn (wiki Wiki) html() string {
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
	return $tmpl('./templates/wiki.html')
}

fn (wiki Wiki) get_index_path(summary string) !string {
	summary_doc := markdownparser.new(content: summary) or {panic(err)}
	index_url := (summary_doc.children[1].children[0].children[0].children[0] as elements.Link).url
	return '${wiki.content_path}/${index_url}'
}