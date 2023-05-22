module library
import freeflowuniverse.crystallib.pathlib { Path }
import freeflowuniverse.crystallib.params
import os

[params]
pub struct ChapterFinderArgs {
pub mut:
	path      string
	heal      bool // healing means we fix images, if selected will automatically load, remove stale links
	load      bool
}


//walk over directory find dis with .site or .chapter inside and add to the book
fn (mut book Book) scan_recursive(args ChapterFinderArgs) ! {
	// $if debug{println(" - chapters find recursive: $path.path")}
	if args.path.len<3{
		return error("Path needs to be not empty.")
	}
	mut path := pathlib.get_dir(args.path, false)!

	if path.is_dir() {
		if path.file_exists('.site'){
			//mv .site file to .chapter file
			chapterfilepath1 := path.extend_file('.site')!
			chapterfilepath2 := path.extend_file('.chapter')!
			os.mv(chapterfilepath1.path,chapterfilepath2.path)!
		}		
		if path.file_exists('.chapter') {
			mut name := path.name()
			mut chapterfilepath := path.file_get('.chapter')!
			
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
			book.chapter_new(path: path.path, name: name,heal:args.heal, load:args.load)!
			return
		}
		mut llist := path.list(recursive: false) or {
			return error('cannot list: ${path.path} \n${error}')
		}
		for mut p_in in llist {
			if p_in.is_dir() {
				if p_in.name().starts_with('.') || p_in.name().starts_with('_') {
					continue
				}

				book.scan_recursive(path:p_in.path, heal:args.heal, load:args.load) or {
					msg := 'Cannot process recursive on ${p_in.path}\n${err}'
					// println(msg)
					return error(msg)
				}
			}
		}
	}
}

pub fn (mut book Book) chapters_scan(args ChapterFinderArgs) ! {
	book.scan_recursive(args)!
	book.fix()!
}