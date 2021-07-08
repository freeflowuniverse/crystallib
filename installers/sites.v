module installers

import cli
import despiegk.crystallib.gittools
import despiegk.crystallib.publisher_config
import despiegk.crystallib.publisher_core
import readline
import os
// import process

pub fn sites_list(cmd &cli.Command) ? {
	mut conf := publisher_config.get() ?
	mut gt := gittools.new(conf.publish.paths.code) or { return error('cannot load gittools:$err') }
	for mut site in conf.sites_get() {
		mut repo := gt.repo_get(name: site.reponame()) or {
			return error('ERROR: cannot get repo:$err')
		}
		change := repo.changes() or {
			return error('cannot detect if there are changes on repo.\n$err')
		}
		mut changed := ''
		mut shortname := ''
		if change {
			changed = ' (CHANGED)'
		}
		if site.shortname != '' {
			shortname = '$site.shortname:  '
		}
		println(' - $shortname$site.name $changed')
	}
}

// if web true then will download websites
pub fn sites_download(cmd cli.Command, web bool) ? {
	mut cfg := config_get(cmd) ?
	mut gt := gittools.new(cfg.publish.paths.code) or { return error('cannot load gittools:$err') }
	// println(' - get all code repositories.')

	for mut sc in cfg.sites {
		if sc.cat == publisher_config.SiteCat.web && !web {
			continue
		}
		if sc.cat == publisher_config.SiteCat.data && !web {
			continue
		}
		println(' - get:$sc.url')
		mut r := gt.repo_get_from_url(url: sc.url, pull: sc.pull, reset: sc.reset, branch: sc.branch) or {
			return error(' - ERROR: could not download site $sc.url, do you have rights?\n$err\n$sc')
		}
		r.check(false, false) ?
	}
}

pub fn sites_install(cmd cli.Command) ? {
	mut cfg := config_get(cmd) ?
	println(' - sites install.')
	mut first := true
	sites_download(cmd, true) ?
	for mut sc in cfg.sites_get() {
		if sc.cat == publisher_config.SiteCat.web {
			website_install(sc.name, first, &cfg) ?
			first = false
		}
	}
}

fn flag_message_get(cmd cli.Command) string {
	flags := cmd.flags.get_all_found()
	msg := flags.get_string('message') or {
		msg := readline.read_line('Message for commit?:') or { panic(err) }
		return msg
	}
	return msg
}

fn flag_repo_do(cmd cli.Command, reponame string, site publisher_config.SiteConfig) bool {
	flags := cmd.flags.get_all_found()
	repo := flags.get_string('repo') or { return true }
	// println("match $reponame $site.shortname")
	if reponame.to_lower().contains(repo.to_lower()) {
		return true
	} else if site.shortname.to_lower().contains(repo.to_lower()) {
		return true
	} else {
		return false
	}
	return true
}

pub fn sites_pull(cmd cli.Command) ? {
	mut cfg := config_get(cmd) ?
	println(' - sites pull.')
	codepath := cfg.publish.paths.code
	mut gt := gittools.new(codepath) or {
		return error_with_code('ERROR: cannot load gittools:$err', 2)
	}
	mut found := false

	for mut sc in cfg.sites_get() {
		mut repo := gt.repo_get(name: sc.reponame()) or {
			return error('ERROR: cannot get repo:$err')
		}
		if !flag_repo_do(cmd, repo.addr.name, sc) {
			continue
		}
		found = true
		println(' - pull  $repo.path')

		if sc.reset {
			repo.check(false, true) ?
		} else {
			repo.pull() or { return error('ERROR: cannot pull repo $repo.path :$err') }
		}
	}

	if !found {
		flags := cmd.flags.get_all_found()
		flags.get_string('repo') or { return }
		return error('ERROR: unknown repo')
	}
}

pub fn sites_push(cmd cli.Command) ? {
	mut cfg := config_get(cmd) ?
	println(' - sites push.')
	codepath := cfg.publish.paths.code
	mut gt := gittools.new(codepath) or { return error('ERROR: cannot load gittools:$err') }

	mut found := false

	for mut sc in cfg.sites_get() {
		mut repo := gt.repo_get(name: sc.reponame()) or {
			return error('ERROR: cannot get repo:$err')
		}
		if !flag_repo_do(cmd, repo.addr.name, sc) {
			continue
		}
		found = true
		println(' - push  $repo.path')
		change := repo.changes() or {
			return error('cannot detect if there are changes on repo.\n$err')
		}
		if change {
			repo.push() or { return error('ERROR: cannot push repo $repo.path :$err') }
			println('     > ok')
		} else {
			println('     > nochange')
		}
	}

	if !found {
		flags := cmd.flags.get_all_found()
		flags.get_string('repo') or { return }
		return error('ERROR: unknown repo')
	}
}

pub fn sites_commit(cmd cli.Command) ? {
	mut cfg := config_get(cmd) ?
	println(' - sites commit.')
	msg := flag_message_get(cmd)
	codepath := cfg.publish.paths.code
	mut gt := gittools.new(codepath) or { return error('ERROR: cannot load gittools:$err') }
	mut found := false

	for mut sc in cfg.sites_get() {
		mut repo := gt.repo_get(name: sc.reponame()) or {
			return error('ERROR: cannot get repo:$err')
		}
		if !flag_repo_do(cmd, repo.addr.name, sc) {
			continue
		}

		found = true
		change := repo.changes() or {
			return error('cannot detect if there are changes on repo.\n$err')
		}
		println(' - $repo.path')
		if change {
			println('     > commit message: $msg')
			repo.commit(msg) or { return error('ERROR: cannot commit repo $repo.path :$err') }
		} else {
			println('     > no change')
		}
	}

	if !found {
		flags := cmd.flags.get_all_found()
		flags.get_string('repo') or { return }
		return error('ERROR: unknown repo')
	}
}

pub fn sites_pushcommit(cmd cli.Command) ? {
	mut cfg := config_get(cmd) ?
	println(' - sites commit, pull, push')
	codepath := cfg.publish.paths.code
	mut gt := gittools.new(codepath) or { return error('ERROR: cannot load gittools:$err') }
	msg := flag_message_get(cmd)

	mut found := false

	for mut sc in cfg.sites_get() {
		mut repo := gt.repo_get(name: sc.reponame()) or {
			return error('ERROR: cannot get repo:$err')
		}
		if !flag_repo_do(cmd, repo.addr.name, sc) {
			continue
		}

		found = true
		println(' - $repo.path')
		change := repo.changes() or {
			return error('cannot detect if there are changes on repo.\n$err')
		}
		if change {
			println('     > commit')
			repo.commit(msg) or { return error('ERROR: cannot commit repo $repo.path :$err') }
		}
		println('     > pull')
		repo.pull() or { return error('ERROR: cannot pull repo $repo.path :$err') }
		if change {
			println('     > push')
			repo.push() or { return error('ERROR: cannot push repo $repo.path :$err') }
		}
	}

	if !found {
		flags := cmd.flags.get_all_found()
		flags.get_string('repo') or { return }
		return error('ERROR: unknown repo')
	}
}

pub fn sites_cleanup(cmd cli.Command) ? {
	mut cfg := config_get(cmd) ?
	println(' - cleanup wiki.')
	mut publisher := publisher_core.new(cfg.publish.paths.code) or { panic('cannot init publisher. $err') }
	publisher.check()
	println(' - cleanup websites.')
	for mut sc in cfg.sites_get() {
		if sc.cat == publisher_config.SiteCat.web {
			website_cleanup(sc.name, &cfg) ?
		} else if sc.cat == publisher_config.SiteCat.wiki {
			wiki_cleanup(sc.name, &cfg) ?
		}
	}
}

pub fn sites_removechanges(cmd cli.Command) ? {
	mut cfg := config_get(cmd) ?
	codepath := cfg.publish.paths.code
	mut gt := gittools.new(codepath) or { return error('ERROR: cannot load gittools:$err') }
	println(' - remove changes')
	for mut sc in cfg.sites_get() {
		mut repo := gt.repo_get(name: sc.reponame()) or {
			return error('ERROR: cannot get repo:$err')
		}

		// script_cleanup := '
		// set -e
		// echo " - cleanup: $repo.path"
		// cd $repo.path

		// rm -f yarn.lock
		// rm -rf .cache		
		// rm -rf modules
		// rm -f .installed
		// rm -rf dist
		// rm -f package-lock.json
		// '

		// process.execute_stdout(script_cleanup) or { return error('cannot cleanup for ${repo.path}.\n$err') }

		if !flag_repo_do(cmd, repo.addr.name, sc) {
			continue
		}
		repo.remove_changes() ?
	}
}

pub fn site_edit(cmd cli.Command) ? {
	mut cfg := config_get(cmd) ?
	codepath := cfg.publish.paths.code
	mut gt := gittools.new(codepath) or { return error('ERROR: cannot load gittools:$err') }
	for mut sc in cfg.sites_get() {
		mut repo := gt.repo_get(name: sc.reponame()) or {
			return error('ERROR: cannot get repo:$err')
		}
		if !flag_repo_do(cmd, repo.addr.name, sc) {
			continue
		}
		// println(' - $repo.path')
		os.execvp('code', [repo.path]) ?
	}
}
