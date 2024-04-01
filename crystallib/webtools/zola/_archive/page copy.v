module zola

import toml
import time
import freeflowuniverse.crystallib.data.doctree
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.markdownparser.elements

// ZolaPage extends doctree page with zola specific metadata
pub struct ZolaPage {
	PageFrontMatter
	// doctree.Page
pub mut:
	name string
	path string
	homepage bool
	template string
	document elements.Doc // markdown document of the page
}

pub struct PageFrontMatter {
	id string
	title string
	description string
	date time.Time
	updated time.Time
	weight int
	draft bool
	slug string @[omitempty]
	path string
	aliases []string
	authors []string
	in_search_index bool = true
	template string 
	taxonomies map[string][]string
	extra map[string]toml.Any
}

pub struct PageAddArgs {
	name       string
	collection string @[required]
	file       string @[required]
	homepage   bool
	template   string
	path    string
}

pub fn (mut site ZolaSite) page_add(args PageAddArgs) ! {
	site.page_add_check_args(args) or { return error('Can\'t add page `${args.name}`: ${err}') }

	mut page := site.tree.page_get('${args.collection}:${args.file}') or {
		println(err)
		return err
	}

}

pub fn (mut site ZolaSite) page_add_helper(path string, page_ ZolaPage) ! {
	file := pathlib.get_file(
		path: path
		create: false
	)!

	if !file.exists() {
		return error('File at path ${path} doesn\'t exist.')
	}

	document := markdownparser.new(path: file.path)!
	for 
	
	page := new_page(
		...page_
		document: markdownparser.new(path: file.path)!

	)!

	// front_matter := page.PageFrontMatter.markdown()
	// zola_page.doc_ = markdownparser.new(content: '${front_matter}\n\n${page.doc()!.markdown()!}')!
	site.pages << zola_page
}

fn new_page(page_ ZolaPage) !ZolaPage {
	mut page := ZolaPage {
		...page_,
		Page: page_.Page
	}
	page.name = texttools.name_fix(page.name)

	if page.taxonomies.values().any('' in it) {
		return error('A taxonomy term cannot be an empty string')
	}
	return page
}

// checks the arguments provided to add page, returns error if error in arguments
fn (mut site ZolaSite) page_add_check_args(args PageAddArgs) ! {
	if site.pages.any(it.name == args.name) {
		return error('page with name `${args.name}` was already added')
	}
	if args.homepage && site.pages.any(it.homepage) {
		homepages := site.pages.filter(it.homepage)
		if homepages.len != 1 {
			panic('this should never happen')
		}
		return error('`${homepages[0].name}` was already added as homepage')
	}
	col := site.tree.collection_get(args.collection) or {
		println(err)
		return err
	}
	page := site.tree.page_get('${args.collection}:${args.file}') or {
		println(err)
		return err
	}
}

pub fn (mut page ZolaPage) export(content_dir string) ! {
	front_matter := page.PageFrontMatter.markdown()
	content := page.doc()!.markdown()!

	if page.homepage {
		page.Page.export(dest: '${content_dir}/home/index.md')!
	} else {
		page.Page.export(dest: '${content_dir}/${page.name}/index.md')!
	}

		mut page_file := pathlib.get_file(path: '${content_dir}/${page.name}/index.md')!
	page_file.write('+++\n${front_matter}\n+++\n${content}')!
}

fn (p PageFrontMatter) markdown() string {
	front_matter := toml.encode(p)
	mut lines := front_matter.split_into_lines()
	for i, mut line in lines {
		if line.starts_with('date = ') {
			if p.date.unix == 0 {
				line = ''
				continue
			}
			line = 'date = ${p.date.ymmdd()}'
		}
		if line.starts_with('updated = ') {
			if p.updated.unix == 0 {
				line = ''
				continue
			}
			line = 'updated = ${p.updated.ymmdd()}'
		}
		else if line.starts_with('slug = ') {
			if p.slug == '' {
				line = ''
				continue
			}
		}
		else if line.starts_with('path = ') {
			if p.path == '' {
				line = ''
				continue
			}
		}else if line.starts_with('template = ') {
			if p.template == '' {
				line = ''
				continue
			}
		}else if line.starts_with('sort_by = ') {
			line = ''
			continue
		}
	}
	return lines.filter(it != '').join_lines()
}