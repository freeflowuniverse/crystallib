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
