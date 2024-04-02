module zola

import freeflowuniverse.crystallib.core.pathlib

pub struct Header {
	template string
	logo     string
pub mut:
	items []HeaderItem
}

type HeaderItem = Dropdown | Link

pub struct HeaderAddArgs {
	items    []HeaderItem
	template string
	logo     string
}

pub fn (mut site ZolaSite) header_add(args HeaderAddArgs) ! {
	site.header = Header{
		logo: args.logo
		template: args.template
	}
}

pub struct Link {
	label   string
	page    string
	new_tab bool
}

pub fn (mut site ZolaSite) header_link_add(args Link) ! {
	mut header := site.header or { return error('header needs to be defined') }
	header.items << args
	site.header = header
}

pub struct Dropdown {
	label   string
	url     string
	new_tab bool
}

pub fn (mut site ZolaSite) header_dropdown_add(args Dropdown) ! {
	site.header!.items << args
}

pub fn (mut header Header) export(content_dir string) ! {
	// header.Page.export(dest: '${content_dir}/header.md')!
	mut content := '---
---
!!flowrift.header
	logo: ${header.logo}
'
	for item in header.items {
		if item is Link {
			content += "\n\n!!flowrift.header_item	
	type:'link'
	label:${item.label}
	url: '${item.page}'"
		}
	}

	mut header_file := pathlib.get_file(path: '${content_dir}/header.md')!
	header_file.write(content)!
}
