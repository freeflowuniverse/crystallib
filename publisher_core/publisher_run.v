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

		println(res)

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
				publisher.flatten2(dest:"")?
			}
		}
	}

}
