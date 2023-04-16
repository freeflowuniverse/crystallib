module library
import freeflowuniverse.crystallib.pathlib { Path }

//walk over directory find dis with .site or .chapter inside and add to the book
fn (mut book Book) chapters_find(mut path pathlib.Path) ! {
	// $if debug{println(" - chapters find recursive: $path.path")}
	if path.is_dir() {
		if path.file_exists('.site') || path.file_exists('.chapter') || {
			mut name := path.name()

			mut chapterfilepath := Path{}
			if path.file_exists('.site') {
				chapterfilepath = path.file_get('.site')!
			}else{
				chapterfilepath = path.file_get('.chapter')!
			}
			
			// now we found a book we need to add
			content := chapterfilepath.read()!
			if content.trim_space() != '' {
				// means there are params in there
				mut params_ := params.parse(content)!
				if params_.exists('name') {
					name = params_.get('name')!
				}
			}
			println(' - chapter new: ${chapterfilepath.path} name:${name}')
			book.chapter_new(path: chapterfilepath.path, name: name)!
			return
		}
		mut llist := path.list(recursive: false) or {
			return error('cannot list: ${path.path} \n${error}')
		}
		for mut p_in in llist {
			if p_in.is_dir() {
				if p_in.path.starts_with('.') || p_in.path.starts_with('_') {
					continue
				}

				book.chapters_find(mut p_in) or {
					msg := 'Cannot process recursive on ${p_in.path}\n${err}'
					// println(msg)
					return error(msg)
				}
			}
		}
	}
}

pub fn (mut books Books) chapters_find(path string) ! {
	mut p := pathlib.get_dir(path, false)!
	books.scan_recursive(mut p)!
	books.fix()!
}