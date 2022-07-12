module publisher_core

// import os
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.publisher_config
import os
import freeflowuniverse.crystallib.actionparser
import freeflowuniverse.crystallib.gittools
//
pub fn get(args publisher_config.PublishConfigArgs) ?Publisher {
	mut publisher := Publisher{
		name: 'main'
	}
	cfg := publisher_config.get(args)?

	// println(cfg)

	// publisher.gitlevel = 0
	publisher.replacer.site = texttools.regex_instructions_new()
	publisher.replacer.file = texttools.regex_instructions_new()
	publisher.replacer.word = texttools.regex_instructions_new()
	publisher.replacer.defs = texttools.regex_instructions_new()
	publisher.config = cfg

	return publisher
}

fn (mut publisher Publisher) load() ? {
	// remove code_wiki subdirs
	path_links := publisher.config.publish.paths.codewiki
	path_links_list := os.ls(path_links)?
	for path_to_remove in path_links_list {
		os.execute_or_panic('rm -f $path_links/$path_to_remove')
	}

	for site in publisher.config.sites {
		if site.cat != publisher_config.SiteCat.wiki {
			continue
		}
		publisher.load_site(site.name)?
	}
	println(' - all sites loaded')

	publisher.check()?
}

// find all actions & process, this works inclusive
fn (mut publisher Publisher) actions_process(actions actionparser.ActionsParser) ?[]string {
	// println("+++++")
	// println(actions)
	// println("-----")

	mut actions_done := []string{}

	mut gt := gittools.get()?

	for action in actions.actions {
		// println( " -- $action")

		// flatten
		// if action.name == 'publish' {
		// 	path := action.param_path_get('path')?
		// 	// now execute the flatten action
		// 	publisher.flatten(dest: path)?
		// 	actions_done << 'publisher.flatten $path'
		// }

		if action.name == 'wiki.publish' {
			publisher.develop = true
			publisher.load()?
			path := action.param_path_get_create('path')? // will also check path exists
			publisher.flatten(dest: path)?
			exit(0)
		}		

		// recursive behavior, include other files and also process
		if action.name == 'actions.include' {
			path := action.param_path_get('path')? // will also check path exists
			mut ap := actionparser.file_parse(path)?
			publisher.actions_process(ap)?
			actions_done << 'actions.include $path'
		}

		if action.name == 'git.params.multibranch' {
			$if debug {
				eprintln(@FN + ': multibranch set')
			}
			gt.multibranch_set()?
		}

		if action.name == 'git.pull' {
			url := action.param_get('url')?
			$if debug {
				eprintln(@FN + ': git pull: $url')
			}
			mut repo := gt.repo_get_from_url(url: url)?
			repo.pull()?
		}

		if action.name == 'wiki.load' {
			mut sc := publisher_config.SiteConfigRaw{}

			// now walk over params
			for param in action.params {
				if param.name == 'name' {
					sc.name = texttools.name_fix(param.value)
				}
				if param.name == 'path' {
					sc.fs_path = param.value
				}
				if param.name == 'url' {
					sc.git_url = param.value
				}
			}
			sc.cat = 'wiki'
			mut site_in := publisher_config.site_new(sc)?
			publisher.config.sites << site_in
		}

		if action.name == 'wiki.run' {
			publisher.develop = true
			publisher.load()?
			webserver_run(mut &publisher) or {
				return error('Could not run webserver for wiki.\nError:\n$err')
			}
			exit(0)
		}


	}
	return actions_done
}

// this is also the place where we process the different actions
pub fn run(args publisher_config.PublishConfigArgs) ?Publisher {
	mut publisher := get(args)?

	mut actions_done := []string{}

	actions_done << publisher.actions_process(publisher.config.actions)?

	// if no actions specified will run development server for the wiki's
	if actions_done.len == 0 {
		publisher.develop = true
		webserver_run(mut &publisher) or {
			println('Could not run webserver for wiki.\nError:\n$err')
			exit(1)
		}
	}

	publisher.load()?

	return publisher
}

// check all pages, try to find errors
pub fn (mut publisher Publisher) check() ? {
	if publisher.init {
		return
	}
	for mut site in publisher.sites {
		if site.config.cat != publisher_config.SiteCat.wiki {
			continue
		}
		site.load(mut publisher)?
	}

	// now the defs are loaded
	// so we can write the default defs pages
	for mut site in publisher.sites {
		if site.config.cat != publisher_config.SiteCat.wiki {
			continue
		}
		// write default def page for all categories
		publisher.defs_init([], ['tech'], mut site, '')
	}

	for mut site in publisher.sites {
		if site.config.cat != publisher_config.SiteCat.wiki {
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
	mut mysite_config := publisher.config.site_get(mysite_name)?

	mysite_config.load()?

	path_links := publisher.config.publish.paths.codewiki

	if mysite_name.trim(' ') == '' {
		return error('mysite_name should not be empty')
	}
	target := '$path_links/$mysite_name'
	if !mysite_config.path.exists() {
		return error('$mysite_config \nCould not find config path (load site).\n   site: $mysite_name >> site path: $mysite_config.path\n')
	}
	os.symlink(mysite_config.path.path_absolute(), target) or {
		return error('cannot symlink for load site in publtools: $mysite_config.path.path to $target \nERROR:\n$err')
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
