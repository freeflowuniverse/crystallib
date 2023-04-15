module library

pub fn (mut chapters Chapters) scan(path string) ! {
	mut p := pathlib.get_dir(path, false)!
	chapters.scan_recursive(mut p)!
}


fn (mut chapter Chapter) scan_recursive(mut path pathlib.Path) ! {
	// $if debug{println(" - chapters scan recursive: $path.path")}
	if path.is_dir() {
		if path.file_exists('.chapter') {
			mut name := path.name()
			mut sitefilepath := path.file_get('.chapter')!
			// now we found a chapter we need to add
			content := sitefilepath.read()!
			if content.trim_space() != '' {
				// means there are params in there
				mut params_ := params.parse(content)!
				if params_.exists('name') {
					name = params_.get('name')!
				}
			}
			println(' - chapter new: ${path.path} name:${name}')
			mut s := chapters.chapter_new(path: path.path, name: name)!
			// find all files in the chapter
			s.scan()!
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

				chapters.scan_recursive(mut p_in) or {
					msg := 'Cannot process recursive on ${p_in.path}\n${err}'
					// println(msg)
					return error(msg)
				}
			}
		}
	}
}


pub fn (mut chapters Chapters) exists(name string) bool {
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	if namelower in chapters.chapters {
		return true
	}
	return false
}

pub fn (mut chapters Chapters) get(name string) !&Chapter {
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	if namelower in chapters.chapters {
		return chapters.chapters[namelower] or { return error('Cannot find chapter ${namelower} in chapters.') }
	}
	return error('could not find chapter with name:${name}')
}

// fix all loaded chapters
pub fn (mut chapters Chapters) fix() ! {
	if chapters.state == .ok {
		return
	}
	for _, mut chapter in chapters.chapters {
		chapter.fix()!
	}
}

pub fn (mut chapters Chapters) sitenames() []string {
	mut res := []string{}
	for key, _ in chapters.chapters {
		res << key
	}
	res.sort()
	return res
}

// walk over all chapters see if we can find the image
// return string if it exists otherwise empty
// the string name (returned argument) is the image with the chapter in form sitename:imagename
// pub fn (mut chapters Chapters) image_name_find(name string) !string {
// 	sitename, namelower := get_chapter_and_obj_name(name, true)!
// 	if sitename != '' {
// 		panic('should not happen, sitename need to be empty')
// 	}
// 	for _, mut site2 in chapters.chapters {
// 		if site2.image_exists(namelower) {
// 			return '${site2.name}:${name}'
// 		}
// 	}
// 	return ''
// }

// internal function
fn (mut chapters Chapters) chapter_get_from_object_name(name string) !&Chapter {
	sitename, _ := get_chapter_and_obj_name(name, true)!
	if sitename == '' {
		return error("Specify the chapter name, format to use is: 'chapter:object', specified:'${name}")
	}
	if sitename in chapters.chapters {
		// means chapter exists
		mut site3 := chapters.chapters[sitename] or { panic('cannot find ${sitename}') }
		return site3
	}
	sitenames := chapters.sitenames().join('\n- ')
	msg := 'Cannot find chapter with name:${sitename} \nKnown sitenames are:\n\n${sitenames}'
	return error(msg)
}

// get the page
// the chapter name needs to be specified
pub fn (mut chapters Chapters) page_get(name string) !&Page {
	_, namelower := get_chapter_and_obj_name(name, true)!
	mut chapter := chapters.chapter_get_from_object_name(name)!
	return chapter.page_get(namelower)!
}

// get the image
// the chapter name needs to be specified
pub fn (mut chapters Chapters) image_get(name string) !&File {
	_, namelower := get_chapter_and_obj_name(name, true)!
	mut chapter := chapters.chapter_get_from_object_name(name)!
	return chapter.image_get(namelower)!
}

// will walk over all chapters, untill it finds the image or the file
pub fn (mut chapters Chapters) image_file_find_over_sites(name string) !&File {
	_, namelower := get_chapter_and_obj_name(name, false)!
	for _, mut chapter in chapters.chapters {
		if chapter.image_exists(namelower) {
			return chapter.image_get(namelower)
		}
		if chapter.file_exists(namelower) {
			return chapter.file_get(namelower)
		}
	}
	return error('could not find image over all chapters: ${name}')
}

// get the file
// the chapter name needs to be specified
pub fn (mut chapters Chapters) file_get(name string) !&File {
	_, namelower := get_chapter_and_obj_name(name, true)!
	mut chapter := chapters.chapter_get_from_object_name(name)!
	return chapter.file_get(namelower)!
}
