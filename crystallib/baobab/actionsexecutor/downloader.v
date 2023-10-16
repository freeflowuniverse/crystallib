module actionsexecutor

import freeflowuniverse.crystallib.data.actionsparser
import freeflowuniverse.crystallib.osal.downloader

//can start with sal, dal, ... the 2nd name is typicall the actor (or topic)
//do this function public and then it breaches out to detail functionality



pub fn sal_downloader(action actionsparser.Action) ! {
	match action.actor {
		"downloader" {
			match action.name {
				"get" {
					downloader_get(action)!
				}
			}
			
		}
	}
}

fn downloader_get(args ActionExecArg) ! {
	action:=args.action
	// context:=args.action or {panic("no context")} //if we need it here
	mut name := action.params.get_default('name', '')!
	mut downloadpath := action.params.get_default('downloadpath', '')!
	mut url := action.params.get_default('url', '')!
	mut reset := action.params.get_default_false('reset')!
	mut gitpull := action.params.get_default_false('gitpull')!

	mut minsize_kb := action.params.get_u32_default('minsize_kb', 0)!
	mut maxsize_kb := action.params.get_u32_default('maxsize_kb', 0)!

	mut destlink := action.params.get_default_false('destlink', '')!

	mut dest := action.params.get_default('dest', '')!
	mut hash := action.params.get_default('hash', '')!
	mut metapath := action.params.get_default('metapath', '')!

	mut meta := downloader.get(
		name: name
		downloadpath: downloadpath
		url: url
		reset: reset
		gitpull: gitpull
		minsize_kb: minsize_kb
		maxsize_kb: maxsize_kb
		destlink: destlink
		dest: dest
		hash: hash
		metapath: metapath
		context:context //TO IMPLEMENT (also optional)
	)!	

}
