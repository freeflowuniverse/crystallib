module publisher_core

import texttools
import os


fn (mut link Link) init_(mut publisher &Publisher, page &Page) {
	// see if its an external link or internal
	// mut linkstate := LinkState.init

	link.original_link = link.original_link.trim(" ")		
	link.description = link.original_descr
	link.page_id_source = page.id


	if link.original_link.contains('://') {
		// linkstate = LinkState.ok
		link.isexternal = true
	}



	if link.original_link.trim(' ').starts_with('http')
		|| link.original_link.trim(' ').starts_with('/')
		|| link.original_link.trim(' ').starts_with('..') {
		link.cat = LinkType.html
		return
	}

	if link.original_link.trim(' ').starts_with('#') {
		link.cat = LinkType.anchor
		return
	}

	//AT THIS POINT LINK IS A PAGE OR A FILE
	////////////////////////////////////////

	if link.original_link.starts_with('!') {
		link.newtab = true
	}
	
	if link.original_link.starts_with('@') {
		link.include = false
	}

	// deal with special cases where file is not the only thing in ()
	if link.original_link.contains(' ') {
		// to support something like
		//![](./img/license_threefoldfzc.png ':size=800x900')
		splitted := link.original_link.split(' ')
		link.filename = splitted[0]
		link.extra = splitted[1]
	} else {
		link.filename = link.original_link
	}

	if link.original_link.starts_with("*"){
		link.filename = link.filename.all_after('*')
		//don't replace original link name, otherwise will not replace
	}		

	if link.filename != '' {
		// lets now check if there is site info in there
		if link.filename.starts_with("!"){
			link.filename = link.filename.after('!')
		}
		if link.filename.starts_with("@"){
			link.filename = link.filename.after('@')
		}
		if link.filename.contains(':') {
			splitted2 := link.filename.split(':')
			if splitted2.len == 2 {
				link.site = texttools.name_fix(splitted2[0])
				if link.site.starts_with('info_') {
					link.site = link.site[5..]
				}
				link.filename = splitted2[1]
			} else if splitted2.len > 2 {
				link.error('link can only have 1 x ":"/n$link')
				return
			} else {
				panic('should never be here')
			}
		}


		base_of_link_filename := os.base(link.filename.replace('\\', '/'))
		link.filename = texttools.name_fix(base_of_link_filename)

		// check which link type
		ext := os.file_ext(link.filename).trim('.').to_lower()

		if ext == '' {
			link.cat = LinkType.page
		} else if ext in ['jpg', 'png', 'svg', 'jpeg', 'gif'] {
			link.isimage = true
			link.cat = LinkType.file			
		} else if ext == 'md' {
			panic('should not happen')
			// link.cat = LinkType.page
		} else if ext in ['html', 'htm'] {
			link.cat = LinkType.html
			return
		} else if ext in ['v', 'py', 'js', 'c', 'sh'] {
			link.cat = LinkType.code
			return
		} else if ext in ['doc', 'docx', 'zip', 'xls', 'pdf', 'xlsx', 'ppt', 'pptx'] {
			link.cat = LinkType.file
			return
		} else if ext in ['json', 'yaml', 'yml', 'toml'] {
			link.cat = LinkType.data
			return
		} else if link.original_link.starts_with('mailto:') {
			link.cat = LinkType.email
			return
		} else if (!link.original_link.contains_any('./?&;')) && !link.isimage {
			// link.cat = LinkType.page
			panic('need to figure out what to dow with $link.original_link ')
		} else {
			// should be a page if no extension
			// link.cat = LinkType.page
			link.error("$link.original_link (no match), ext was:'$ext'")
			return
		}		

		if link.cat == LinkType.page {
			mut linktocheck := link.filename
			if linktocheck.starts_with("!") || linktocheck.starts_with("@") {
				println(linktocheck)
				panic("should never be here")
			}
			// println(" ****  $link.page_id_source ${page.path}-> $link.filename")
			// println('link, find page ($linktocheck): ${link.original_link}.')
			item_linked := publisher.page_find(linktocheck, link.page_id_source) or {
				// println(link)
				link.error("link, cannot find page: '$linktocheck' \n$err")
				return
			}
			link.page_id_dest = item_linked.id
			link.site = item_linked.site_name_get(mut publisher)
		}else if link.cat == LinkType.file {
			mut linktocheck := link.original_link
			mut item_linked := publisher.file_find(linktocheck, link.page_id_source) or {
				link.error('link, cannot find file: ${link.original_link}.\n$err')
				return
			}
			link.filename = item_linked.name(mut publisher)
			link.page_id_dest = item_linked.id
			link.site = item_linked.site_name_get(mut publisher)
			//remember that the page has been used by a file
			if !(page.id in item_linked.usedby) {
				item_linked.usedby << page.id
			}
		}

	

		if link.filename.contains(':') {
			panic("should not have ':' in link for page or file (2).\n$link")
		}

		// check if there are pagename or sitename changes
		// NOT SUPPORTED FOR NOW
		// if link.site != '' {
		// 	sitename_replaced := publisher.replacer.site.replace(text:link.site) or { panic(err) }
		// 	if link.site != sitename_replaced {
		// 		link.site = sitename_replaced
		// 	}
		// }
		// filename_replaced := publisher.replacer.file.replace(text:link.filename) or { panic(err) }
		// if link.filename != filename_replaced {
		// 	link.filename = filename_replaced
		// }


		if link.filename == '' {
			if !link.original_link.trim(' ').starts_with('#') {
				link.state = LinkState.error
				link.error( "EMPTY LINK: for '$link.original_get()'")
				return
			}
		}

		if link.site == '' {
			panic("should not be empty")
		}

		// mut linkname := ''
		// //page is the page where the link is on, so will return the site at source
		// mut sourcesite := page.site_get(mut publisher) or {
		// 	panic("cannot find site in page")
		// }

		// if link.cat == LinkType.page {
		// 		mut page_linked2 := link.page_dest_get(mut publisher) or {
		// 		panic('link, cannot find page: ${link.original_link}.\n$err')
		// 		// return 
		// 	}
		// 	//site is the source site
		// 	linkname = page_linked2.name_get(mut publisher, sourcesite.id)
		// }else if link.cat == LinkType.file {
		// 		mut file_linked2 := link.file_get(mut publisher) or {
		// 		panic('link, cannot find file link: ${link.original_link}.\n$err')
		// 		// return 
		// 	}
		// 	linkname = file_linked2.name_with_site(mut publisher, sourcesite.id)or {
		// 		panic('link, cannot find file link: ${link.original_link}.\n$err')
		// 		// return 
		// 	}
		// }
		// // only process links if page or file
		// if linkname != link.filename {
		// 	println(" '$linkname' <> '${link.filename}'")
		// 	link.debug_info(mut publisher,"LINKNAME CHANGE")
		// 	// link.filename = linkname
		// 	// link.init_(mut publisher)
		// }

		//GOOD DEBUG TRICK
		// if link.cat == LinkType.page {

		// 	if link.original_link.contains("@manual3_home"){
		// 		link.debug_info(mut publisher,"TEMP")
		// 	}
		// }

	}
}

fn (mut link Link) debug_info(mut publisher Publisher, msg string)  {
	println ("  ######### DEBUG: $msg")
	mut page_source := link.page_source_get(mut publisher) or { panic(err) }
	mut page_dest := link.page_dest_get(mut publisher) or { panic(err) }
	mut site_source := link.site_source_get(mut publisher) or { panic(err) }
	mut site_dest := link.site_dest_get(mut publisher) or { panic(err) }				
	source_link := link.source_get(site_source, mut publisher) or {panic("ss")}
	dest_link := link.server_get(mut publisher)
	println(link)
	println("    - sourcepage: ${page_source.path}")
	println("    - sourcesite: ${site_source.name}")
	println("    - sourcelink: $source_link")
	println("    - destpage: ${page_dest.path}")
	println("    - destsite: ${site_dest.name}")
	println("    - serverlink: $dest_link")		
	panic("link debug info")		
}

//###########################################################################

fn (link Link) original_get() string {
	mut l := '[$link.original_descr]($link.original_link)'
	if link.isimage {
		l = '!$l'
	}
	return l
}

fn (link Link) original_get_with_ignore() string {
	mut l := "[$link.original_descr]($link.original_link ':ignore')"
	if link.isimage {
		l = '!$l'
	}
	return l
}


// return how to represent link on server
// page is the page from where the link is on
fn (mut link Link) server_get(mut publisher &Publisher) string {

	// println(link.original_link)
	
	if link.cat == LinkType.page {
		mut page_source := link.page_source_get(mut publisher) or { 
			println( " cannot find the page at source for link:\n$link")
			panic(err) 
		}
		mut page_dest := link.page_dest_get(mut publisher) or { 
			println( " cannot find the page at dest for link:\n$link")
			panic(err) 
		}
		site_dest := page_dest.site_get(mut publisher) or { 
			println( " cannot find site for destpage for link:\n$link")
			panic(err) 
		}
		site_source := page_source.site_get(mut publisher) or { 
			println( " cannot find site for source page for link:\n$link")
			panic(err) 
		}

		if link.newtab == false {
			if link.include{
				mut page_sidebar1 := page_source.sidebar_page_get(mut publisher) or { 
					println( " cannot find sidebar for source page:$page_source.path for link:\n$link")
					panic(err) 
				}
				mut path_sidebar1 := page_sidebar1.path_dir_relative_get(mut publisher).trim(" /")
				// println(path_sidebar1)
				// println(link)
				// println( '[$link.description](/${path_sidebar1}/${link.filename}.md)')
				// panic("sser")
				return '[$link.description](/$path_sidebar1/${link.filename}.md)'
			}
			if page_dest.sidebarid > 0 && link.filename.to_lower()!="readme" && link.filename.to_lower()!="defs"{
				// return '[$link.description](${link.site}__${link.filename}.md)'	

				mut page_sidebar := page_dest.sidebar_page_get(mut publisher) or { 
					println( " cannot find sidebar for dest page:$page_dest.path for link:\n$link")
					panic(err) 
				}
				mut path_sidebar := page_sidebar.path_dir_relative_get(mut publisher).trim(" /")

				// println(" - serverget: path_sidebar:$path_sidebar $link.filename")


				// if path_sidebar != ""{
				// if link.original_link.to_lower().contains("threefold_home"){
				// 	println(" - serverget: path_sidebar:$path_sidebar $link.filename")	
				// 	println("    = $site_source.name $site_dest.name $link.site ")
				// }

				if site_source.name != site_dest.name{
					return '<a href="/info/${link.site}/#/$path_sidebar/${link.filename}.md"> $link.description </a>'
					// return '[$link.description](/info/${link.site}/#/$path_sidebar/${link.filename}.md)'	
					// return '[$link.description](../${link.site}/$path_sidebar/${link.filename}.md)'	
				}else{
					return '[$link.description](/$path_sidebar/${link.filename}.md)'
				}

			}
			if site_source.name != site_dest.name{
			// return '<a href="/info/${link.site}/#/$link.filename"> $link.description </a>'
				return '<a href="/info/${link.site}/#/$link.filename"> $link.description </a>'
			}else{
				return '[$link.description](${link.site}__${link.filename}.md)'	
			}
		}else{
			// return '[$link.description](/${link.site}/${link.filename}.md \':target=_blank\')'
			return '<a href="/info/${link.site}/#/$link.filename" target="_blank"> $link.description </a>'
		}
		
	}
	if link.cat == LinkType.file {
		if link.isimage {
			// return '![$link.description](${link.site}__$link.filename  $link.extra)'
			if link.extra==""{
				return '![$link.description](${link.site}__$link.filename)'
			}else{
				return '![$link.description](${link.site}__$link.filename $link.extra)'
			}
			
		}
		// return '[$link.description](/${link.site}__$link.filename  $link.extra)'
		if link.extra == '' {
			return '<a href="${link.site}__$link.filename"> $link.description </a>'
		} else {
			return '<a href="${link.site}__$link.filename $link.extra"> $link.description </a>'
		}
	}
	return link.original_get_with_ignore()
}

// return how to represent link on source
fn (mut link Link) source_get(site &Site, mut publisher &Publisher) ?string {
	// println(" >>< $sitename $link.site")
	if link.cat == LinkType.page {
		if link.filename.contains(':') {
			panic("should not have ':' in link for page or file.\n$link")
		}		
		if link.isimage{
			if site.image_exists(link.filename){
				mut file := site.image_get(link.filename, mut publisher)?
				if file.exists(mut publisher){
					panic("file $file should exist.")
				}
				return '[$link.description](${file.name(mut publisher)})'
			}			
		}
		sitename := site.name
		if sitename == link.site {
			if link.include{
				return '[$link.description]($link.filename)'
			}else if link.newtab{
				return '[$link.description](!$link.filename)'
			}else{
				return '[$link.description](@$link.filename)'
			}
		} else {
			if link.include{
				return '[$link.description]($link.site:$link.filename)'
			}else if link.newtab{
				return '[$link.description](!$link.site:$link.filename)'
			}else{
				return '[$link.description](@$link.site:$link.filename)'
			}
		}
	}
	if link.cat == LinkType.file {
		if link.filename.contains(':') {
			panic('should not have in link for page or file.\n$link')
		}
		mut filename := ''

		if link.isimage {
			filename = 'img/$link.filename'
		} else {
			filename = '$link.filename'
		}

		mut j := ''

		if link.extra == '' {
			j = '[$link.description]($filename)'
		} else {
			j = '[$link.description]($filename $link.extra)'
		}

		if link.isimage {
			j = '!$j'
		}

		return j
	}
	return link.original_get()
}

// replace original link content in text with $replacewith
fn (link Link) replace(text string, replacewith string) string {
	return text.replace(link.original_get(), replacewith)
}


