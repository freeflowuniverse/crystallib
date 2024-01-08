module zola

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.web.zola as zola_installer
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.data.ourtime
import freeflowuniverse.crystallib.ui.console
import time
import os

@[heap]
pub struct Zola {
pub mut:
	sites           []&ZSite                    @[skip; str: skip]
	gitrepos        map[string]gittools.GitRepo
	gitrepos_status map[string]RepoStatus
	coderoot        string
	path_build      string
	path_publish    string
	gitstructure    gittools.GitStructure       @[skip; str: skip]
	reset           bool
}

pub struct RepoStatus {
pub mut:
	revlast string
	revnew  string
}

@[params]
pub struct ZolaArgs {
pub mut:
	coderoot    string = '${os.home_dir()}/hero/code'
	buildroot   string = '${os.home_dir()}/hero/var/wsbuild'
	publishroot string = '${os.home_dir()}/hero/www'
	install     bool   = true
	reset       bool
}

pub fn new(args ZolaArgs) !Zola {
	zola_installer.install()!
	mut gs := gittools.get(coderoot: args.coderoot)!
	mut sites := Zola{
		coderoot: args.coderoot
		path_build: args.buildroot
		path_publish: args.publishroot
		gitstructure: gs
		reset: args.reset
	}

	return sites
}

fn (mut self Zola) generate() ! {
	// now we generate all sites
	for mut site in self.sites {
		site.generate()!
	}
	// now we have to reset the rev keys, so we remember current status
	for key, mut status in self.gitrepos_status {
		osal.done_set('zolarev_${key}', status.revnew)!
		status.revlast = status.revnew
	}
}

// get all content
pub fn (mut self Zola) pull() ! {
	println(self)
	for key, repo_ in self.gitrepos {
		mut repo := repo_
		if self.reset {
			repo.pull_reset(reload: true)! // need to overwrite all changes
		} else {
			repo.pull(reload: true)! // will not overwrite changes
		}
		revnew := repo.rev()!
		lastrev := osal.done_get('zolarev_${key}') or { '' }
		self.gitrepos_status[key] = RepoStatus{
			revnew: revnew
			revlast: lastrev
		}
	}
	self.generate()!
}

@[params]
pub struct WatchArgs {
pub mut:
	period int = 300 // 5 min default
}

pub fn (mut self Zola) watch(args WatchArgs) {
	mut t := ourtime.now()
	mut last := i64(0)
	for {
		t.now()
		println('${t} ${t.unix_time()} period:${args.period}')
		if t.unix_time() > last + args.period {
			console.print_header(' will try to check the websites for zola.')
			self.pull() or { " - ERROR: couldn't check the repo's.\n${err}" }
			last = t.unix_time()
		}
		time.sleep(time.second)
		if args.period == 0 {
			return
		}
	}
}

pub fn build()
