module zola

import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.osal
// import log
// import os

// TODO: the idea is we can also pull in parts of websites in one mother website e.g. for blogs, just like we do for wiki

pub struct ZSiteCollection {
pub mut:
	site       &ZSite       @[skip; str: skip]
	name       string
	url        string
	reset      bool
	pull       bool
	gitrepokey string
	path       pathlib.Path
}

@[params]
pub struct ZSiteCollectionArgs {
pub mut:
	name string
	url  string
}

pub fn (mut b ZSite) playbook_add(args_ ZSiteCollectionArgs) ! {
	mut args := args_
	mut c := ZSiteCollection{
		url: args.url
		name: args.name
		site: &b
	}
	b.playbooks << c
}

pub fn (mut self ZSiteCollection) prepare() ! {
	println(' - zola playbook prepare: ${self.url}')
	mut gs := self.site.sites.gitstructure
	mut locator := gs.locator_new(self.url)!
	mut repo := gs.repo_get(locator: locator, reset: false, pull: false)!
	self.site.sites.gitrepos[repo.key()] = repo
	self.gitrepokey = repo.key()
	self.path = locator.path_on_fs()!
	self.path.link('${self.site.path_build.path}/src/${self.name}', true)!
}
