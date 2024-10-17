module data

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.markdownparser.elements
import freeflowuniverse.crystallib.data.doctree3.pointer

pub fn (mut page Page) process_links(paths map[string]string) ![]string {
	mut not_found := []string{}
	mut doc := page.doc()!
	for mut element in doc.children_recursive() {
		if mut element is elements.Link {
			mut name := texttools.name_fix_keepext(element.filename)
			mut site := texttools.name_fix(element.site)
			if site == '' {
				site = page.collection_name
			}

			pointerstr := '${site}:${name}'
			p := pointer.pointer_new(pointerstr)!

			mut path_name := '${p.collection}:${p.name}.${p.extension}'
			if p.extension == '' {
				path_name += '.md'
			}

			mut path := paths[path_name] or {
				not_found << pointerstr
				continue
			}

			if site == page.collection_name {
				// same directory
				path = './' + path.all_after_first('/')
			} else {
				path = '../${path}'
			}

			if element.cat == .image && element.extra.trim_space() != '' {
				path += ' ${element.extra.trim_space()}'
			}

			out := '![${element.description}](${path})'
			element.content = out
			element.processed = false
			element.process()!
		}
	}

	return not_found
}
