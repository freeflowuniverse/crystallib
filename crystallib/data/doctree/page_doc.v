module doctree

import freeflowuniverse.crystallib.data.markdownparser.elements { Action, Doc, Include, Link, Paragraph }
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.core.texttools
// import freeflowuniverse.crystallib.core.pathlib
import os

[params]
pub struct DocArgs{
pub mut:
	heal_export bool = true
	heal_source bool
	dest string //if we want to relocate images for links
}

fn (mut page Page) doc(args DocArgs) !Doc {

	mut mydoc := markdownparser.new(path: page.path.path)!
	mut collection:=page.collection()!

	// mut tostop:=false
	// if page.name == "planet_people_first"{
	// 	tostop=true
	// 	println(mydoc.treeview())
	// }

	if args.heal_export{

		d:=mydoc.children_recursive() 
		//find the links, and for each link check if collection is same, is not need to copy
		for mut element in mydoc.children_recursive() {
			if mut element is Link{
				// println(element)
				name := texttools.name_fix(element.filename)
				mut site := texttools.name_fix(element.site)
				if site==""{
					site=collection.name
				}
				pointername:="${site}:${name}"
				// println("POINTER "+pointername)
				if element.cat==.image{
					if page.tree.image_exists(pointername){
						mut linkimage:=page.tree.image_get(pointername)!
						if linkimage.collection.name != collection.name{
							if args.dest.len==0 || !(os.exists(args.dest)){
								collection.error(path: page.path, 
									msg: 'image found but could not relocated, dest not specified: ${pointername}', 
									cat: .image_not_found)
								continue
							}
							mut dest_image_copy:="${args.dest}/img/${linkimage.file_name()}"
							linkimage.copy(dest_image_copy)!						
						}
						mut out:=""
						if element.extra.trim_space() == '' {
							out = '![${element.description}](img/${linkimage.file_name()})'
						} else {
							out = '![${element.description}](img/${linkimage.file_name()} ${element.extra})'
						}						
						mydoc.content_set(element.id,out)

					}else{
						collection.error(path: page.path, msg: 'image not found: ${pointername}', cat: .image_not_found)
					}
				}
				
				if element.cat==.page{
					if page.tree.page_exists(pointername){
						mut linkpage:=page.tree.page_get(pointername)!
						// println("exists")
						// println(linkpage)
						mut collection_linkpage:=linkpage.collection()!
						// println("${collection_linkpage.name}   ----   ${collection.name}  ")
						if collection_linkpage.name != collection.name {
							if args.dest.len==0 || !(os.exists(args.dest)){
								collection.error(path: page.path, 
									msg: 'page found but could not relocated, dest not specified: ${pointername}', 
									cat: .image_not_found)
								continue
							}
							mut dest_page_copy:="${args.dest}/${linkpage.name}.md"
							linkpage.export(dest:dest_page_copy)!				
							// println(dest_page_copy)
						}						
						mut out := '[${element.description}](${linkpage.name}.md)'
						mydoc.content_set(element.id,out)
						
					}else{
						collection.error(path: page.path, msg: 'page not found: ${pointername}', cat: .page_not_found)
					}
				}				
			}
		}	

	}
	// if tostop{panic('s333s')}

	return mydoc

}

