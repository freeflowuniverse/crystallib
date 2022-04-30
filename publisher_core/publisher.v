module publisher_core
// import os
import texttools
import publisher_config
import os

//
pub fn get(args publisher_config.PublishConfigArgs) ?Publisher {
	
	mut publisher := Publisher{name:"main"}

	cfg := publisher_config.get(args)?

	println(cfg)

	// publisher.gitlevel = 0
	publisher.replacer.site = texttools.regex_instructions_new()
	publisher.replacer.file = texttools.regex_instructions_new()
	publisher.replacer.word = texttools.regex_instructions_new()
	publisher.replacer.defs = texttools.regex_instructions_new()
	publisher.config = cfg

	// remove code_wiki subdirs
	path_links := cfg.publish.paths.codewiki
	path_links_list := os.ls(path_links) ?
	for path_to_remove in path_links_list {
		os.execute_or_panic('rm -f $path_links/$path_to_remove')
	}

	for site in publisher.config.sites {
		if site.cat != publisher_config.SiteCat.wiki {
			continue
		}
		publisher.load_site(site.name)?
	}
	println( " - all sites loaded")
	
	return publisher
}


pub fn run(args publisher_config.PublishConfigArgs) ?Publisher {

	mut publisher := get(args)?

	mut didsomething := false

	for action in publisher.config.actions.actions{

		//flatten
		if action.name == "publish"{
			mut path:=""
			for param in action.params{
				if param.name=="path"{
					path = param.value
				}
			}
			//now execute the flatten action
			publisher.flatten(dest:path)?
		}
	}

	//if no actions specified will run development server for the wiki's
	if didsomething == false{
		publisher.develop = true
		webserver_run(mut &publisher) or {
			println('Could not run webserver for wiki.\nError:\n$err')
			exit(1)
		}

	}

	return publisher

}


// check all pages, try to find errors
pub fn (mut publisher Publisher) check() ? {
	if publisher.init{
		return
	}
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
	
	publisher.init = true

}

// returns the found locations for the sites, will return [[name,path]]
pub fn (mut publisher Publisher) site_locations_get() [][]string {
	mut res := [][]string{}
	for site in publisher.sites {
		res << [site.name, site.path]
	}
	return res
}




///////////////////////////////////////////////////////// INTERNAL BELOW ////////////////
/////////////////////////////////////////////////////////////////////////////////////////

// load a site into the publishing tools
// name of the site needs to be unique
fn (mut publisher Publisher) load_site(name string) ? {
	
	mysite_name := texttools.name_fix(name)
	mut mysite_config := publisher.config.site_get(mysite_name) ?

	mysite_config.load()?

	path_links := publisher.config.publish.paths.codewiki	

	if mysite_name.trim(" ")==""{
		return error("mysite_name should not be empty")
	}
	target := '$path_links/$mysite_name'
	if ! mysite_config.path.exists(){
		return error("$mysite_config \nCould not find config path (load site).\n   site: $mysite_name >> site path: $mysite_config.path\n")
	}
	os.symlink(mysite_config.path.path_absolute(), target) or {
		return error("cannot symlink for load site in publtools: $mysite_config.path.path to $target \nERROR:\n$err")
	}

	println(' - load publisher: $mysite_config.name - $mysite_config.path.path')
	if !publisher.site_exists(name) {
		id := publisher.sites.len
		mut site := Site{
			id: id
			path: mysite_config.path.path
			name: mysite_config.name
			config: &mysite_config
		}
		// site.config = &mysite_config
		publisher.sites << site
		publisher.site_names[mysite_config.name] = id
	} else {
		return error("should not load on same name 2x: '$mysite_config.name'")
	}
	// println(' - load publisher: $mysite_config.name - $mysite_config.path OK')

}
