module doctree

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import os
import freeflowuniverse.crystallib.core.texttools

@[params]
pub struct TreeExportArgs {
pub mut:
	dest  string @[required]
	reset bool = true
}

// export all collections to chosen directory .
// all names will be in name_fixed mode .
// all images in img/
pub fn (mut tree Tree) export(args_ TreeExportArgs) ! {
	console.print_green("export tree: name:${tree.name} to ${args_.dest}")
	mut args := args_

	mut path_src := pathlib.get_dir(path: '${args.dest}/src', create: true)!
	mut path_edit := pathlib.get_dir(path: '${args.dest}/edit', create: true)!

	if args.reset {
		path_src.empty()!
		path_edit.empty()!
	}

	tree.defs(args_)! //process definitions

	for name, mut collection in tree.collections {
		mut collection_linked_pages:=[]string{}
		console.print_green("export collection: name:${name}")		
		dir_src := pathlib.get_dir(path: path_src.path + '/' + name, create: true)!

		collection.path.link('${path_edit.path}/${name}', true)!

		mut cfile := pathlib.get_file(path: dir_src.path + '/.collection', create: true)! // will auto safe it
		cfile.write("name:${name} src:'${collection.path.path}'")!

		for _, mut page in collection.pages {
			mut mydoc:=page.export(dest: '${dir_src.path}/${page.name}.md')!
			for linked_page in mydoc.linked_pages{
				if !(linked_page in collection_linked_pages){
					collection_linked_pages<<linked_page
				}
			}
		}

		for _, mut file in collection.files {
			mut d := '${dir_src.path}/img/${file.name}.${file.ext}'
			if args.reset || !os.exists(d) {
				file.copy(d)!
			}
		}

		for _, mut file in collection.images {
			mut d := '${dir_src.path}/img/${file.name}.${file.ext}'
			if args.reset || !os.exists(d) {
				file.copy(d)!
			}
		}
		collection.errors_report('${dir_src.path}/errors.md')!

		mut linked_pages_file := pathlib.get_file(path: dir_src.path + '/.linkedpages', create: true)! 
		linked_pages_file.write(collection_linked_pages.join_lines())!
	}
}


pub fn (mut tree Tree) defs(args_ TreeExportArgs) ! {

	for name, mut collection in tree.collections {
		// console.print_green("get defs for collection:${name}")		
		for pagekey in collection.pages.keys() {
			mut page := collection.pages[pagekey] or {panic('bug')}
			console.print_debug("get defs for page:${page.key()}")
			mut mydoc := page.doc()!
			mut res:=mydoc.actionpointers(actor:"wiki",name:"def")
			if res.len>0{
				//means there is a wiki def defined
				for action_element in res{
					my_action:=action_element.action
					for alias in my_action.params.get_list("alias")!{
						alias2 := texttools.name_fix(alias).replace("_","")
						if alias2 in tree.defs{
							collection.error(path:page.path,msg:"def double defined: ${alias}",cat:.def)
						}else{
							tree.defs[alias2]=page
						}
					}
				}
			}
		}
	}
	mut mydef_page2:= tree.defs["threefolddev"] or {panic("bug")}

	for collection_name in tree.collections.keys() {
		mut collection := tree.collections[collection_name] or {panic("bug")}
		console.print_green("process defs for collection:${collection_name}")		
		for name in collection.pages.keys() {
			mut mypage := collection.pages[name] or {panic("bug")}
			mut mydoc := mypage.doc()!
			for mut defitem in mydoc.defpointers(){
				defname:=defitem.name() 
				println(defname)
				if defname in tree.defs{
					mut mydef_page:= tree.defs[defname] or {panic("bug")}
					mydoc2:=mydef_page.doc()!
					// println(mydef_page.key())
					// panic("found def")
					defitem.pagekey=mydef_page.key()
					// println(defitem.markdown())
				}else{
					collection.error(path:mypage.path,msg:"def not found: '${defname}'",cat:.def)
				}
				
			}
		}
	}	
	panic("macro")					

	// for macro in tree.get_macros(name:"def",actor:"wiki")!{
	// 	println(macro)
	// 	if true{
	// 		panic("macro")
	// 	}
	// }

}