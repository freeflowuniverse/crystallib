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


// //relative path in the site
// fn (mut page Page) path_in_site(mut link Link) ? {

// 	imagelink_rel := pathlib.path_relative(page.site.path.path, fileobj.path.path)?
	
// 	return page.site

// }

fn (mut page Page) fix_link(mut link Link) ? {
	mut file_name := link.filename
	// $if debug {
	// 	println(' - fix link $link.original with name:$file_name for page: $page.path.path')
	// }
	//empty just to fill in on next 
	mut fileobj:=File{site:page.site}

	//if its not an image, we can only check if it exists, if not return and report error
	if link.cat == .file{			
		if ! page.site.file_exists(file_name){
			msg := "'$file_name' not found for page:$page.path.path"
			page.site.error(path: page.path, msg:  "file $msg", cat: .file_not_found)
			return
		}
		fileobj = page.site.file_get(file_name)or {panic(err)}//should never get here
	}else{
		if ! page.site.image_exists(file_name){
			file_name2 := page.site.sites.image_find(file_name)?
			if file_name2==""{
				//we could not find the filename not even in other sites
				msg := "'$file_name' not found for page:$page.path.path"
				page.site.error(path: page.path, msg:  "image $msg", cat: .image_not_found)
				link.description = "not found: ${link.filename}"
				page.doc.content = link.replace(page.doc.content,"")?
				page.doc.save()?
				return
			}else{
				file_name=file_name2
			}
		}
		fileobj = page.site.image_get(file_name) or {panic(err)}//should never get here
		//copy the file if it exists in other site than from this page
		if page.site.name != fileobj.site.name {
			if !(file_name.contains(":")) && page.site.image_exists(file_name){
				mut msg:="the file '$file_name' as pointed too is not from this site but it also existed in this site."
				msg+="\npage site name: $page.site.name"
				msg+="\nfile site name: $fileobj.site.name"
				// page.site.error(cat:.file_double,msg:msg)
				panic(msg)
			}else{
				//means we are not in same site, we can copy to this site
				mut dest := pathlib.get("${page.path.path_dir()}/img/${fileobj.path.name()}")			
				pathlib.get_dir("${page.path.path_dir()}/img",true)? //make sure it exists
				fileobj.path.copy(mut dest)?
				page.site.image_new(mut dest)? //make sure site news about the new file
				fileobj =  page.site.image_get(fileobj.name)? //get the file now from the site we are in from this pager

			}
		}		
	}

	if fileobj.path.is_link() {
		fileobj.path.unlink()?//make a real file, not a link
	}			

	//means we now found the file or image
	page.files_linked << &fileobj

	imagelink_rel := pathlib.path_relative(page.path.path_dir(), fileobj.path.path)?
	link.description = ""
	link.link_update(imagelink_rel,true)?


}

// checks if external link returns 404
// if so, prompts user to replace with new link
fn (mut page Page) fix_external_link(mut link Link) ? {
	// TODO: check if external links works
	// TODO: do error if not exist
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
					page.fix_link(mut link)?
				}
			}
		}
	}
}


fn (mut page Page) save(dest string) ? {
	mut p:= pathlib.get_file(dest,true )?
	p.write(page.doc.content)?
}