module data

import freeflowuniverse.crystallib.core.pathlib
import rand

fn test_process_def_pointers() {
	// create three pages
	// one of them with def pointers to the other two
	// processed page should have links to the other two pages
	mut page1_path := pathlib.get_file(path: '/tmp/page1', create: true)!
	alias1, alias2 := rand.string(5).to_upper(), rand.string(5).to_upper()
	page1_content := '*${alias1}\n*${alias2}'
	page1_path.write(page1_content)!
	mut page1 := new_page(name: 'page1', path: page1_path, collection_name: 'col1')!

	mut page2_path := pathlib.get_file(path: '/tmp/page2', create: true)!
	mut page2 := new_page(name: 'page2', path: page2_path, collection_name: 'col1')!
	page2.alias = 'page2 alias'

	mut page3_path := pathlib.get_file(path: '/tmp/page3', create: true)!
	mut page3 := new_page(name: 'page3', path: page2_path, collection_name: 'col2')!
	page3.alias = 'my page3 alias'

	mut defs := map[string]&Page{}
	defs['${alias1.to_lower()}'] = &page2
	defs['${alias2.to_lower()}'] = &page3

	page1.process_def_pointers(defs)!

	assert page1.get_markdown()! == '[page2 alias](col1:page2.md)\n[my page3 alias](col2:page3.md)'
}
