module zola

import freeflowuniverse.crystallib.data.doctree
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib

// ZolaPage extends doctree page with zola specific metadata
pub struct ZolaPage {
	doctree.Page
pub mut:
	homepage bool
	template string
}

pub struct PageAddArgs {
	name string 
	collection string @[required]
	file string @[required]
	homepage bool
	template string
}

pub fn (mut site ZolaSite) page_add(args PageAddArgs) ! {
	site.page_add_check_args(args) or {
		return error('Can\'t add page `${args.name}`: ${err}')
	}

	page := site.tree.page_get('${args.collection}:${args.file}') or {
		println(err)
		return err
	}

	zola_page := new_zola_page(
		name: args.name
		page: page
		homepage: args.homepage
		template: args.template
	)
	site.pages << zola_page
}

struct ZolaPageArgs {
	page doctree.Page
	name string
	homepage bool
	template string
}

fn new_zola_page(args ZolaPageArgs) ZolaPage {
	doctree_page := doctree.Page {
		...args.page
		name: texttools.name_fix(args.name)
	}

	return ZolaPage{
		Page: args.page
		homepage: args.homepage
		template: args.template
	}
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
	if page.homepage {
		page.Page.export(dest: '${content_dir}/home/index.md')!
	} else {
		page.Page.export(dest: '${content_dir}/${page.name}/index.md')!
	}
}
