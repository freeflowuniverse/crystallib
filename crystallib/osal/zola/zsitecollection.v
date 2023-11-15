module zola

// import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.osal
// import log
// import os

// TODO: the idea is we can also pull in parts of websites in one mother website e.g. for blogs, just like we do for wiki

pub struct ZSiteCollection {
pub mut:
	site       &ZSite [skip; str: skip]
	name       string
	url        string
	reset      bool
	pull       bool
	gitrepokey string
}

[params]
pub struct ZSiteCollectionArgs {
pub mut:
	name  string
	url   string
	reset bool
	pull  bool
}

pub fn (mut self ZSiteCollection) get() ! {
	println(' - zola collection get: ${self.url}')
	mut gs := self.site.sites.gitstructure
	mut locator := gs.locator_new(self.url)!
	mut repo := gs.repo_get(locator: locator, reset: self.reset, pull: self.pull)!
	self.site.sites.gitrepos[repo.key()] = repo

	mut srcpath := locator.path_on_fs()!

	println(' - zola collection: ${srcpath}')
}
