module publisher_core

import freeflowuniverse.crystallib.texttools

struct Def {
	name   string
	pageid int
	hidden bool
mut:
	categories []string
}

// walk over categories, see if we can find the prefix
pub fn (def Def) category_prefix_exists(prefix_ string) bool {
	prefix := prefix_.to_lower()
	for cat in def.categories {
		if cat.starts_with(prefix) {
			return true
		}
	}
	return false
}

pub fn (mut def Def) categories_add(categories []string) {
	for cat_ in categories {
		cat := texttools.name_fix_no_underscore(cat_)
		if cat !in def.categories {
			def.categories << cat
		}
	}
}

pub fn (def Def) page_get(mut publisher Publisher) ?&Page {
	return publisher.page_get_by_id(def.pageid)
}

pub fn (def Def) name_fixed() ?string {
	return texttools.name_fix_no_underscore(def.name)
}

// create a defs page, which is linked to site
// the defs page has a macro which lists all defs as found in site
fn (mut publisher Publisher) defs_init(categories []string, exclude []string, mut site Site, name_ string) {
	mut name := name_
	if name == '' {
		name = 'defs'
	}

	// for defobjin publisher.defs  {
	// 	// defobj := publisher.defs[defname]
	// 	mut page := publisher.page_get_by_id(defobj.pageid) or { panic(err) }
	// 	//add replacer for the definitions TODO: see if works ok
	// 	//NOT NEEDED NOW
	// 	// publisher.replacer.defs.add(['${defname}:[defobj.name](${site.name}__${page.name}.md)']) or {
	// 	// 	panic(err)
	// 	// }
	// }

	if name !in site.pages {
		categories2 := categories.join(',')
		exclude2 := exclude.join(',')
		content := "!!!def_list categories:'$categories2' exclude:'$exclude2'\n"

		// attach this def page to the site
		page := Page{
			id: publisher.pages.len
			site_id: site.id
			name: name
			content: content
			path: '${name}.md'
		}
		publisher.pages << page
		site.pages[name] = publisher.pages.len - 1
		// if page.path_exists(mut publisher){
		// 	panic("should never be here, page path cannnot exists.\n Now: ${page.path_get(mut publisher)}")
		// }
		page.write(mut publisher, page.content)
	}
}

fn (mut publisher Publisher) def_page_get(name string) ?&Page {
	def := publisher.def_get(name)?
	return def.page_get(mut publisher)
}

// replace in text the defs to a link
fn (mut publisher Publisher) replace_defs_links(mut page Page, text string) ?string {
	if page.name == 'defs' {
		return page.content
	}
	site_source := page.site(mut publisher)
	mut replacer := map[string]string{}

	mut page_sidebar := page.sidebar_page_get(mut publisher) or { panic(err) }
	mut path_sidebar := page_sidebar.path_dir_relative_get(mut publisher).trim(' /')

	for defname, defid in publisher.def_names {
		if page.name == defname {
			continue
		}
		defobj := publisher.def_get_by_id(defid)?
		if defobj.pageid == 999999 {
			println(' = skip def: $defname $defid')
			panic('skip def')
			continue
		}
		page2 := defobj.page_get(mut publisher)?
		site2 := page2.site(mut publisher)

		mut link := page2.name
		if site2.name != site_source.name {
			link = '${site2.name}__$page2.name'
		}

		if path_sidebar == '' {
			replacer[defname] = '[$defobj.name]($link)'
			replacer[defname + 's'] = '[${defobj.name}s]($link)'
		} else {
			replacer[defname] = '[$defobj.name](/$path_sidebar/$link)'
			replacer[defname + 's'] = '[${defobj.name}s](/$path_sidebar/$link)'
		}
	}
	// println(text)
	// println("=======================")
	// println(replacer)
	result := texttools.replace_items(text, replacer)
	// println(result)
	return result
}
