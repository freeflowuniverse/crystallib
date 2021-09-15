module installers

import crystallib.publisher_config
import crystallib.publisher_core

import os

pub fn sites_list(names []string) ? {
	mut conf := publisher_config.get()
	println("\033[2J")
	println("\n ===== list of sites =====\n")
	for mut site in conf.sites_get(names) {
		mut repo := site.repo_get()
		change := repo.changes() or {
			return error('cannot detect if there are changes on repo.\n$err')
		}
		mut changed := ''
		if change {
			changed = ' (CHANGED)'
		}
		println(' - $site.name  ${site.repo_get().addr.url_http_get()} $changed')
	}
	println("\n")
}

pub fn sites_install(names []string) ? {
	mut conf := publisher_config.get()
	println(' - sites install.')
	mut first := true
	for mut sc in conf.sites_get(names) {		
		// println(sc)
		if sc.cat == publisher_config.SiteCat.web {
			website_install([sc.name], first) ?
			first = false
		} else if sc.cat == publisher_config.SiteCat.wiki {
			wiki_install([sc.name]) ?
		}
	}
}


pub fn sites_pull(names []string) ? {
	mut conf := publisher_config.get()
	println(' - sites pull.')
	for mut sc in conf.sites_get(names) {
		mut repo := sc.repo_get()
		println(' - pull  $repo.path()')
		if sc.reset {
			repo.check(false, true) ?
		} else {
			repo.pull() or { return error('ERROR: cannot pull repo $repo.path() :$err') }
		}
	}

}

pub fn sites_push(names []string) ? {
	mut conf := publisher_config.get()
	println(' - sites push.')
	for mut sc in conf.sites_get(names) {
		mut repo := sc.repo_get()
		println(' - push  $repo.path()')
		change := repo.changes() or {
			return error('cannot detect if there are changes on repo.\n$err')
		}
		if change {
			repo.push() or { return error('ERROR: cannot push repo $repo.path() :$err') }
			println('     > ok')
		} else {
			println('     > nochange')
		}
	}

}

pub fn sites_commit(msg string,names []string) ? {
	mut conf := publisher_config.get()
	println(' - sites commit.')
	for mut sc in conf.sites_get(names) {
		mut repo := sc.repo_get()
		// println(sc)
		change := repo.changes() or {
			return error('cannot detect if there are changes on repo.\n$err')
		}
		println(' - $repo.path()')
		if change {
			println('     > commit message: $msg')
			repo.commit(msg) or { return error('ERROR: cannot commit repo $repo.path() :$err') }
		} else {
			println('     > no change')
		}
	}
}


pub fn sites_discard(names []string) ? {
	mut conf := publisher_config.get()
	println(' - sites discard.')
	for mut sc in conf.sites_get(names) {
		mut repo := sc.repo_get()
		// println(sc)
		println(' - $repo.path()')
		repo.remove_changes() ?
	}
}


pub fn sites_pushcommit(msg string, names []string) ? {
	mut conf := publisher_config.get()
	println(' - sites commit, pull, push')
	for mut sc in conf.sites_get(names) {
		mut repo := sc.repo_get()
		println(' - $repo.path()')
		change := repo.changes() or {
			return error('cannot detect if there are changes on repo.\n$err')
		}
		if change {
			println('     > commit')
			repo.commit(msg) or { return error('ERROR: cannot commit repo $repo.path() :$err') }
		}
		println('     > pull')
		repo.pull() or { return error('ERROR: cannot pull repo $repo.path() :$err') }
		if change {
			println('     > push')
			repo.push() or { return error('ERROR: cannot push repo $repo.path() :$err') }
		}
	}
}

pub fn sites_cleanup(names []string) ? {
	mut conf := publisher_config.get()
	println(' - cleanup wiki.')
	mut publisher := publisher_core.new(conf) ?
	publisher.check() ?
	println(' - cleanup websites.')
	for mut sc in conf.sites_get(names) {
		if sc.cat == publisher_config.SiteCat.web {
			website_cleanup(sc.name) ?
		} else if sc.cat == publisher_config.SiteCat.wiki {
			wiki_cleanup([sc.name]) ?
		}
	}
}

pub fn sites_removechanges(names []string) ? {
	mut conf := publisher_config.get()
	println(' - remove changes')
	for mut sc in conf.sites_get(names) {
		mut repo := sc.repo_get()
		// script_cleanup := '
		// set -e
		// echo " - cleanup: $repo.path()"
		// cd $repo.path()

		// rm -f yarn.lock
		// rm -rf .cache		
		// rm -rf modules
		// rm -f .installed
		// rm -rf dist
		// rm -f package-lock.json
		// '
		// process.execute_stdout(script_cleanup) or { return error('cannot cleanup for ${repo.path()}.\n$err') }
		repo.remove_changes() ?
	}
}

pub fn site_edit(name string) ? {
	mut conf := publisher_config.get()
	for mut sc in conf.sites_get([name]) {		
		mut repo := sc.repo_get()
		// println(' - $repo.path()')
		os.execvp('code', [repo.path()]) ?
	}
}
