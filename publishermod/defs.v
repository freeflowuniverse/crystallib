module publishermod

struct Def {
	name   string
	pageid int
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
		cat := cat_.to_lower()
		if !(cat in def.categories){
			def.categories<<cat
		}
	}	

}

fn (mut publisher Publisher) defs_page_get(categories []string) {
	mut firstletter := ' '
	mut out := []string{}
	mut firstletter_found := ''

	out << '# Definitions & Concepts'
	out << ''

	mut def_names := []string{}

	for defname, _ in publisher.defs {
		def_names << defname
	}
	def_names.sort()

	for defname in def_names {
		defobj := publisher.defs[defname]
		firstletter_found = defname[0].ascii_str()
		if firstletter_found != firstletter {
			out << ''
			out << '## $firstletter_found'
			out << ''
			out << '| def | description |'
			out << '| ---- | ---- |'
			firstletter = firstletter_found
		}
		mut page := publisher.page_get_by_id(defobj.pageid) or { panic(err) }

		site := page.site_get(mut publisher) or { panic(err) }

		publisher.replacer.defs.add(['defname:[defobj.name](${site.name}__${page.name}.md)']) or {
			panic(err)
		}

		deftitle := page.title()

		out << '| [$defobj.name](${site.name}__${page.name}.md) | $deftitle |'
	}

	out << ''

	content := out.join('\n')

	// attach this page to the sites in the publisher
	for mut site in publisher.sites {
		page := Page{
			id: publisher.pages.len
			site_id: site.id
			name: 'defs'
			content: content
			path: 'defs.md'
		}
		publisher.pages << page
		site.pages['defs'] = publisher.pages.len - 1
		// page.write(mut publisher, page.content)
	}
}

fn (mut publisher Publisher) def_page_get(name string) ?&Page {
	name2 := name_fix_no_underscore(name)
	if name2 in publisher.defs {
		pageid := publisher.defs[name2].pageid
		// println(publisher.pages.map(it.id))
		// println(':::$pageid:::')
		if pageid in publisher.pages.map(it.id) {
			return &publisher.pages[pageid]
		} else {
			panic('BUG: Cannot find page with $pageid in pages, for def:$name\n')
		}
	}
	if publisher.defs.len == 0 {
		panic('defs need to be loaded first')
	}
	return error("Cannot find page for def:'$name'\n")
}

fn (mut publisher Publisher) def_page_exists(name string) bool {
	name2 := name_fix_no_underscore(name)
	if name2 in publisher.defs {
		pageid := publisher.defs[name2].pageid
		if pageid in publisher.pages.map(it.id) {
			return true
		} else {
			panic('BUG: Cannot find page with $pageid in pages, for def:$name\n')
		}
	}
	if publisher.defs.len == 0 {
		panic('defs need to be loaded first')
	}
	return false
}
