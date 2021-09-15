module publisher_core
// import os
import texttools
import publisher_config

// the factory, get your tools here
// use path="" if you want to go from os.home_dir()/code/
// will find all wiki's
pub fn new(config &publisher_config.ConfigRoot) ?Publisher {
	mut publisher := Publisher{}
	// publisher.gitlevel = 0
	publisher.replacer.site = texttools.regex_instructions_new()
	publisher.replacer.file = texttools.regex_instructions_new()
	publisher.replacer.word = texttools.regex_instructions_new()
	publisher.replacer.defs = texttools.regex_instructions_new()
	publisher.config = config
	publisher.load()?

	return publisher
}

// check all pages, try to find errors
pub fn (mut publisher Publisher) check() ? {
	for mut site in publisher.sites {
		if site.config.cat != publisher_config.SiteCat.wiki{
			continue
		}
		site.load(mut publisher)?
	}

	// now the defs are loaded
	// so we can write the default defs pages
	for mut site in publisher.sites {
		if site.config.cat != publisher_config.SiteCat.wiki{
			continue
		}
		// write default def page for all categories
		publisher.defs_init([], ['tech'], mut site, '')
	}

	for mut site in publisher.sites {
		if site.config.cat != publisher_config.SiteCat.wiki{
			continue
		}
		site.process(mut publisher)?
	}
}

// returns the found locations for the sites, will return [[name,path]]
pub fn (mut publisher Publisher) site_locations_get() [][]string {
	mut res := [][]string{}
	for site in publisher.sites {
		res << [site.name, site.path]
	}
	return res
}

// replace in text the defs to a link
fn (mut publisher Publisher) replace_defs_links(mut page &Page) ?string {

	text := page.content
	mut replacer := map[string]string{}

	mut page_sidebar := page.sidebar_page_get(mut publisher) or { panic(err) }
	mut path_sidebar := page_sidebar.path_dir_relative_get(mut publisher).trim(" /")
	// println(" ==== $path_sidebar")

	for defname, defid in publisher.def_names {
		if page.name == defname{
			continue
		}
		defobj := publisher.def_get_by_id(defid) ?
		page2 := defobj.page_get(mut publisher) ?
		site2 := page2.site(mut publisher)
		if path_sidebar == ""{
			replacer[defname] = '[$defobj.name](${site2.name}__$page2.name)'
			replacer[defname+"s"] = '[${defobj.name}s](${site2.name}__$page2.name)'
		}else{
			replacer[defname] = '[$defobj.name](/$path_sidebar/${site2.name}__$page2.name)'
			replacer[defname+"s"] = '[${defobj.name}s](/$path_sidebar/${site2.name}__$page2.name)'
		}
	}
	result := texttools.replace_items(text, replacer)
	return result
}
