module publisher_core

import texttools
import os
import path

fn (mut publ Publisher) name_fix_alias_page(name string) ?string {
	// name0 := name
	name0 := publ.replacer.file.replace(text:name) ?
	return texttools.name_fix(name0)
}

fn (mut publ Publisher) name_fix_alias_site(name string) ?string {
	name0 := publ.replacer.site.replace(text:name) ?
	return texttools.name_fix(name0)
}

fn (mut publ Publisher) name_fix_alias_file(name string) ?string {
	name0 := publ.replacer.file.replace(text:name) ?
	return texttools.name_fix_keepext(name0)
}

//returns name without extension and _ from image
//returns name with extension for normal file
//all is lower case & normalized
fn (mut publisher Publisher)  path_get_name_fix(pathin string) string {
	mut patho := path.get_file(pathin,false)
	mut namelower := ""
	if patho.is_image(){			
		namelower = publisher.name_fix_no_underscore_no_ext(patho.name()) or {panic("cannot fix image name")}
	}else{
		namelower = publisher.name_fix_alias_file(patho.name()) or {panic("cannot fix file name")}
	}
	return namelower
}


//gets name, lower case, normalize, remove extension, right trim _
fn (mut publ Publisher) name_fix_no_underscore_no_ext(name string) ?string {
	name0 := publ.replacer.file.replace(text:name) ?
	return texttools.name_fix_no_underscore_no_ext(name0)
}

fn (mut publ Publisher) name_fix_alias_word(name string) ?string {
	name0 := publ.replacer.file.replace(text:name) ?
	return name0.trim(' ')
}

fn (mut publ Publisher) name_split_alias(name string) ?(string, string) {
	mut site_name, mut obj_name := name_split(name) ?
	site_name = publ.name_fix_alias_site(site_name) ?
	ext := os.file_ext(obj_name).trim('.')
	if ext == '' || ext == 'md' {
		obj_name = publ.name_fix_alias_page(obj_name) ?
	} else {
		obj_name = publ.name_fix_alias_file(obj_name) ?
	}
	return site_name, obj_name
}

// check if the file can be found and add the file to the site if needed
// it will also rename the file if needed
fn (mut publisher Publisher) file_find_(name2find string, consumer_page_id int) ?&File {
	consumer_page := publisher.page_get_by_id(consumer_page_id) or { panic(err) }
	mut consumer_site := consumer_page.site_get(mut publisher) or { panic(err) }

	mut filesres := publisher.files_get(name2find)
	if filesres.len == 0 {
		return error('cannot find the file: $name2find')
	}
	for mut f in filesres {
		if (*f).site_id == consumer_site.id {
			// we found a file in the right site, nothing to do
			mut file2 := publisher.file_get_by_id((*f).id) ?
			file2.consumer_page_register(consumer_page_id, mut publisher)
			return file2
		}
	}
	// means we found files but we don't have it in our site, we need to copy
	mut file_source := filesres[0]
	file_source_path := file_source.path_get(mut publisher)
	dest := '$consumer_site.path/img_tosort/${os.base(file_source_path)}'
	println(" - $consumer_page.name cp:$file_source_path $dest")
	os.cp(file_source_path, dest) or { panic(err) }

	// will remember new file and will make sure rename if needed happens, but should already be ok
	file := consumer_site.file_remember_full_path(dest, mut publisher)?

	// we know the name is in right site
	return file
}

// check if we can find the file, if not copy to site if found in other site
// we check the file based on name & replaced version of name
fn (mut publisher Publisher) file_find(name2find string, consumer_page_id int) ?&File {
	if consumer_page_id==999999{
		mut consumer_page2 := publisher.page_get_by_id(consumer_page_id) or { panic(err) }
		println(consumer_page2)
		panic("consumer page id cannot be 999999")
	}
	// didn't find a better way how to do it, more complicated than it should I believe
	mut consumer_page := publisher.page_get_by_id(consumer_page_id) or { panic(err) }
	mut consumer_site := consumer_page.site_get(mut publisher) or { panic(err) }
	_, mut objname := name_split(name2find) or { panic(err) }
	// mut objname_full := '$consumer_site.name:$objname'

	//this is for when we have replacements to be done, normally this is not the case
	//can be defined as metadata in config (or at least was like that)
	objname_replaced := publisher.replacer.file.replace(text:objname) or { panic(err) }

	for x in 0 .. 4 {

		//find the image in the site of where the page is
		if x == 0 {
			zzz := consumer_site.file_get(objname, mut publisher) or { continue }
			return zzz
		}

		//find the image with site name or without can be e.g. cloud:afile or afile
		if x == 1 {
			zzz := publisher.file_find_(name2find, consumer_page_id) or { continue }
			return zzz
		}

		if x == 2 {
			//if name2find not done yet they look for file on objname only
			if objname != name2find {
				zzz := publisher.file_find_(objname, consumer_page_id) or { continue }
				return zzz
			}
		}

		if x == 3 {
			//if replace instruction is there, then do the replace and look for it
			if objname != objname_replaced {
				zzz := publisher.file_find_(objname_replaced, consumer_page_id) or { continue }
				return zzz
			}
		}
	}

	// we did not manage to find a file, not even after replace
	return error('cannot find the file: $name2find')
}

// check if the page can be found over all sites
// is used by page_find , page_find does for multiple name combinations, this one only for 1
fn (mut publisher Publisher) page_find_(name2find string, consumer_page_id int) ?&Page {

	mut res := publisher.pages_find(name2find)

	if res.len == 0 {
		return error('cannot find the page: $name2find')
	}
	if res.len > 1 {
		// we found more than 1 result, not ok cannot continue
		mut consumer_page := publisher.page_get_by_id(consumer_page_id) or { panic(err) }
		mut msg := 'we found more than 1 page for $name2find in source page:$consumer_page.name, doubles found:\n '
		for p in res {
			msg += '<br> - ${p.path_get(mut publisher)}<br>'
		}
		msg = msg.trim(',')
		consumer_page.error_add(PageError{ msg: msg, cat: PageErrorCat.doublepage }, mut publisher)
		return error('found more than 1 page: $name2find')
	}
	return res[0]
}

pub fn (mut publisher Publisher) healcheck() bool{
	mut heal:= false
	if "HEAL" in os.environ(){
		// println("#### WARNING HEALING MODE, CHECK CHANGES ###")
		heal= true
	}
	return heal
}

// check if we can find the page, page can be on another site|
// we also check definitions because they can also lead to right page
pub fn (mut publisher Publisher) page_find(name2find_ string, consumer_page_id int) ?&Page {
	// println (" == page find: $name2find")
	if consumer_page_id==999999{
		panic("consumer page id cannot be 999999")
	}
	mut consumer_page := publisher.page_get_by_id(consumer_page_id) or {
		panic('page get by id:$consumer_page_id\n$err')
	}
	mut consumer_site := consumer_page.site_get(mut publisher) or { panic("site_get:'n$err") }

	//if healing then will look for more files to fix, find files more easily
	//can be dangerous !!!
	heal := publisher.healcheck()

	//if we heal then we look for moresites
	mut moresites := heal
	mut name2find := name2find_
	if name2find.starts_with("*"){
		//will look over multiple sites
		name2find = name2find.all_after("*")
		moresites = true		
	}

	sitename , objname := name_split(name2find) ?
	// mut objname_replaced := publisher.replacer.file.replace(text:objname) or {
	// 	panic('file_replace:\n$err')
	// }

	if moresites && sitename != "" && heal == false {
		//is error because can not do wildcard search if sitename has been specified
		return error("can not do wildcard search if sitename has been specified for $name2find")
	}


	// didn't find a better way how to do it, more complicated than it should I believe
	for x in 0 .. 4 {

		//check name can be found as mentioned with full name
		if sitename != ''{
			if x == 0  {
				// first check if we can find the page with full original name, if not is error
				zzz := publisher.page_find_('$sitename:$objname', consumer_page_id) or { continue }
				return zzz
			}else{
				if ! heal{
					return error('cannot find the page: $name2find, looked on site \'$sitename\'.')
				}
			}
		}

		//lets now check that we can find the name in the site itself, if yes is ok
		if x == 1  {
			// first check if we can find the page in the site itself
			zzz := publisher.page_find_('$consumer_site.name:$objname', consumer_page_id) or { continue }
			return zzz
		}

		if x == 2 && moresites {
			// lets now check on name over all sites
			// println(" -- find: '$sitename' '$objname' (moresites)")
			zzz := publisher.page_find_(objname, consumer_page_id) or { continue }
			// println(" --- FOUND")
			return zzz
		}

		if x == 3 {
			// lets now try if we can get if from definitions
			zzz := publisher.def_page_get(objname) or { continue }
			return zzz
		}

		// if x == 3 && name2find != objname {
		// 	// now check if we can find it more generic
		// 	zzz := publisher.page_find_(objname, consumer_page_id) or { continue }
		// 	return zzz
		// }

		// if x == 3 {
		// 	zzz := publisher.page_find_(objname_replaced, consumer_page_id) or { continue }
		// 	return zzz
		// }


		// if x == 5 {
		// 	// lets now try if we can get if from definitions but replaced
		// 	zzz := publisher.def_page_get(objname_replaced) or { continue }
		// 	return zzz
		// }
	}
	// we did not manage to find a page
	return error('cannot find the page: $name2find')
}
