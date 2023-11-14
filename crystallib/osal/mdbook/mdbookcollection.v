module mdbook

// import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.osal
// import log
// import os

pub struct MDBookCollection {
pub mut:
	book       &MDBook [skip; str: skip]
	name       string
	url        string
	reset      bool
	pull       bool
	gitrepokey string
}

[params]
pub struct MDBookCollectionArgs {
pub mut:
	name  string
	url   string
	reset bool
	pull  bool
}

pub fn (mut book MDBook) collection_add(args_ MDBookCollectionArgs) ! {
	mut args := args_
	mut c := MDBookCollection{
		url: args.url
		name: args.name
		book: &book
	}
	c.get()!
	book.collections << c
}

pub fn (mut self MDBookCollection) get() ! {
	println(' - mdbook collection get: ${self.url}')
	mut gs := self.book.books.gitstructure
	mut locator := gs.locator_new(self.url)!
	mut repo := gs.repo_get(locator: locator, reset: self.reset, pull: self.pull)!
	self.book.books.gitrepos[repo.key()] = repo
	self.gitrepokey = repo.key()

	mut srcpath := locator.path_on_fs()!
	println('debugzo: ${srcpath}')
	srcpath.link('${self.book.path_build.path}/src/${self.name}', true)!

	// println(srcpath)

	println(' - mdbook collection: ${srcpath}')
}
