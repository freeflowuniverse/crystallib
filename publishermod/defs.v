module publishermod

struct Def {
	name   string
	pageid int
	hidden bool
mut:
	categories []string
}


//walk over categories, see if we can find the prefix
pub fn (def Def) category_prefix_exists(prefix_ string) bool {
	prefix := prefix_.to_lower()
	for cat in def.categories{
		if cat.starts_with(prefix){
			return true
		}
	}
	return false
}

pub fn (mut def Def) categories_add(categories []string){
	for cat_ in categories{
		cat := name_fix_no_underscore(cat_)
		if !(cat in def.categories){
			def.categories<<cat
		}
	}	

}

pub fn (def Def) page_get(mut publisher &Publisher) ?&Page {
	return publisher.page_get_by_id(def.pageid)
}

pub fn (def Def) name_fixed() string {
	return name_fix_no_underscore(def.name)
}




fn (mut publisher Publisher) defs_init(categories []string, exclude []string, mut site &Site, name_ string) {

	mut name := name_
	if name == "" {
		name = "defs"
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

	if ! (name in site.pages){

		categories2 := categories.join(",")
		exclude2 := exclude.join(",")
		content := "!!!def_list categories:'${categories2}' exclude:'${exclude2}'\n"

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
