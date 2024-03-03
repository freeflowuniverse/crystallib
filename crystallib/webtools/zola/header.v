module zola

import freeflowuniverse.crystallib.data.doctree
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib

pub struct Header {
	template string
pub mut:
	items []HeaderItem
}

type HeaderItem = Link | Dropdown

pub struct HeaderAddArgs {
	items []HeaderItem
	template string
}


pub fn (mut site ZolaSite) header_add(args HeaderAddArgs) ! {
	site.header = Header{
		template: args.template
	}
}

pub struct Link {
	label string
	page string
	new_tab bool
}

pub fn (mut site ZolaSite) header_link_add(args Link) ! {
	println('debugzort')
	site.header!.items << args
}

pub struct Dropdown {
	label string
	url string
	new_tab bool
}

pub fn (mut site ZolaSite) header_dropdown_add(args Dropdown) ! {
	site.header!.items << args
}

pub fn (mut header Header) export(content_dir string) ! {
	// header.Page.export(dest: '${content_dir}/header.md')!
	println('debugzort: ${header}')
	mut content := "---
---
!!flowrift.header
"
	for item in header.items {
		content += "!!flowrift.header_item	
type:'link'
label:Test
url: 'test.md'"
	}

	mut header_file := pathlib.get_file(path: '${content_dir}/header.md')!
	header_file.write(content)!
}