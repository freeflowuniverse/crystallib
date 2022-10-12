module books

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.markdowndocs { Link }
import os

pub enum PageStatus {
	unknown
	ok
	error
}

[heap]
pub struct Page {
pub mut: // pointer to site
	name           string // received a name fix
	site           &Site            [str: skip]
	path           pathlib.Path
	pathrel        string
	state          PageStatus
	pages_included []&Page          [str: skip]
	pages_linked   []&Page          [str: skip]
	files_linked   []&File          [str: skip]
	categories     []string
	doc            markdowndocs.Doc [str: skip]
}

// will return true if it had to fix
// return false if not good, error
fn (mut page Page) fix_location(mut link Link) ?bool {
	file_name := link.name_fix_no_underscore_no_ext()
	$if debug {
		println(' - fix link $link.original with name:$file_name for page: $page.path.path')
	}
	mut fileobj := &File{
		site: page.site
	}

	// it refers to an image
	if link.cat == .image {
		if page.site.image_exists(file_name, page.site.sites.config.heal) {
			fileobj = page.site.image_get(file_name, page.site.sites.config.heal)?
		} else {
			msg := 'image:$file_name not found for page:$page.path.path'
			page.site.error(path: page.path, msg: msg, cat: .file_not_found)
			$if debug {
				println(msg)
			}
			return false
		}
	} else {
		if page.site.file_exists(file_name, page.site.sites.config.heal) {
			fileobj = page.site.file_get(file_name, page.site.sites.config.heal)?
		} else {
			msg := 'file:$file_name not found for page:$page.path.path'
			$if debug {
				println(msg)
			}
			page.site.error(path: page.path, msg: msg, cat: .file_not_found)
			return false
		}
	}

	// means we found a file can be in this site or any other site from this sites collection
	file_path_real := fileobj.path.realpath()
	dir_path_real := pathlib.get(page.path.path_dir() + '/img').realpath() + '/'.replace('//', '/')
	if file_path_real.starts_with(dir_path_real) {
		return true
	}

	if fileobj.path.is_link() {
		println(page)
		println(file_path_real)
		println(dir_path_real)
		println(fileobj.path)
		panic('bug: the file always needs to be a real one not a link')
	}
	println(fileobj)
	dest := '$dir_path_real' + fileobj.path.name()
	println(dest)
	mut dest_obj := pathlib.get(dest)
	mut file_path_real_obj := pathlib.get(file_path_real)
	if dest_obj.exists() && file_path_real_obj.exists() {
		// this means source exists for sure, destination too, so have double, one can go
		dest_obj.delete()?
	}
	if !dest_obj.exists() {
		println('1:$file_path_real_obj')
		file_path_real_obj.link(dest_obj.path, true)?
		println(2)
	}
	return true
}

fn (mut page Page) fix_link(mut link Link) ? {
	name := link.filename.all_before_last('.').trim_right('_').to_lower().replace('_', '')
	$if debug {
		println('fixing image link: $name $link')
	}
	// TODO: page.site.files to save filename using namefix with underscores
	if name in page.site.files {
		originalfilename := link.filename
		image := page.site.files[name]

		mut source := page.pathrel.all_before_last('/') // this is the relative path of where the page is in relation to site root
		$if debug {
			println('getting relative link: $source  $image.pathrel')
		}
		mut imagelink_rel := pathlib.path_relative(page.path.path, image.path.path)?

		// updates the link to the image correctly
		if link.link_update(imagelink_rel) {
			// SHORTCUT
			page.doc.content = page.doc.content.replace(originalfilename, link.filename)
			$if debug {
				println('change: $originalfilename -> $link.filename')
			}
			page.doc.save()?
		}
	} else {
		page.site.error(
			path: page.path
			msg: 'could not find image: $name in site:$page.site.name'
			cat: .file_not_found
		)
	}
	// replace;: image alt text  in link because has no meaning
}

// checks if external link returns 404
// if so, prompts user to replace with new link
fn (mut page Page) fix_external_link(mut link Link) ? {
	// TODO: check if external links works
	// TODO: prompt user for new link
}

fn (mut page Page) fix() ? {
	page.fix_links()?
}

// walk over all links and fix them with location
// TODO: inquire about use of filter below
fn (mut page Page) fix_links() ? {
	// mut changed := false

	for mut item in page.doc.items.filter(it is markdowndocs.Paragraph) {
		if mut item is markdowndocs.Paragraph { //? interestingly necessary despite filter
			for mut link in item.links {
				if link.isexternal {
					page.fix_external_link(mut link)?
				} else if link.cat == .image || link.cat == .file {
					page.fix_location(mut link)?
					page.fix_link(mut link)?
				}
			}
		}
	}
}

// fn (mut page Page) fix_file_link(mut link Link) ? {
// 	name := link.filename.all_before_last('.').trim_right('_').to_lower()
// 	if name in page.site.pages {
// 		originalfilename := link.filename
// 		original_link := '$link.path/$link.filename'
// 		page_linked := page.site.pages[name]
// 		mut source := page.pathrel.all_before_last('/') // this is the relative path of where the page is in relation to site root
// 		mut filelink_rel := pathlib.path_relative(source, page_linked.pathrel)?
// 		if link.link_update(filelink_rel) {
// 			if original_link.trim_space() != filelink_rel.trim_space() {
// 				page.doc.content = page.doc.content.replace(originalfilename, link.filename)
// 				println('change: $original_link -> $filelink_rel')
// 			}
// 			page.doc.save()?
// 			//? There use to be panic here, does this work as it's supposed to?
// 			// panic('to do link update')
// 		}
// 	} else {
// 		page.site.error(
// 			path: page.path
// 			msg: 'could not find page: $name in site:$page.site.name'
// 			cat: .page_not_found
// 		)
// 	}
// }
// }
