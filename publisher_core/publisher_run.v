module publisher_core

import texttools
import os
import publisher_config
import actionparser


pub fn (mut publisher Publisher) run() ? {
	// remove code_wiki subdirs
	cfg := publisher_config.get()?
	//lets now find commands in config

	for md_file in cfg.markdown_configs{

		res := actionparser.parse(md_file)?

		// println(res)

		mut didsomething := false

		for action in res.actions{
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
	}

}
