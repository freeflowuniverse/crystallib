module wikicreator

import os
// import texttools

pub fn (mut creator WikiCreator) do(path string,path_out string) ? {
	mut path2 := path.replace('~', os.home_dir())
	mut path_out2 := path.replace('~', os.home_dir())
	return creator.do_recursive(path2,path_out2)
}

///////////////////////////////////////////////////////// INTERNAL BELOW ////////////////
/////////////////////////////////////////////////////////////////////////////////////////

// find all wiki's, this goes very fast, no reason to cache
fn (mut creator WikiCreator) do_recursive(path_root string,path_out string) ? {
	if path_root == '' || ! os.exists(path_root){
		return error("cannot load wiki processing from path: $path_root, does not exist")
	}
	if path_root == '' {
		return error("cannot load wiki processing for dest path, because empty")
	}
	if ! path.exists(path_out){
		os.mkdir_all(path_out) ?
	}

	return creator.do_recursive_(path_root,path_out)
}

fn (mut creator WikiCreator) do_recursive_(path string,path_out string) ? {
	items := os.ls(path) ?
	mut pathnew := ""
	for item in items {
		pathnew = os.join_path(path, item)
		println(' - $item')
		if os.is_link(pathnew) {
			continue
		}
		if item.starts_with('.') {
			continue
		}
		if item.starts_with('_') {
			continue
		}
		if os.is_dir(os.join_path(path, item)) {
			creator.files_process_recursive(pathnew,path_out) ?
		} else {
			if item.to_lower() == 'defs.md' {
				continue
			} else if item.contains('.test') {
				os.rm(pathnew) ?
				continue
			} 
			// for names we do everything case insensitive
			mut itemlower := item.to_lower()
			mut ext := os.file_ext(itemlower).trim(".")

			mut item2 := item

			if ext == '' || ext != "md" {continue}
			
			println(item2)
		}
	}
}

// fn (mut site WikiCreatorSite) page_remember(path string, name string) ? {
// 	println(' - page remember:$path/$name')
// 	name2 := texttools.name_fix_keepext(name)
// 	if name2.starts_with('story') {
// 		o := obj_new<Story>('$path/$name') ?
// 		println(o)
// 	}
// }
