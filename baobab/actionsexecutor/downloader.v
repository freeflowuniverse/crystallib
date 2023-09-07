module actionsexecutor

import freeflowuniverse.crystallib.baobab.actions
import freeflowuniverse.crystallib.baobab.context
import freeflowuniverse.crystallib.osal.downloader

fn downloader(mut c context.Context, mut actions actions.Actions, action action.Action) ! {
	if action.name == 'get' {
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
		)!
	}
}
