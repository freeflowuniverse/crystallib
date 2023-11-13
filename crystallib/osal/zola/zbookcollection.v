module zola

// import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.osal
// import log
// import os


pub struct ZBookCollection {
pub mut:
	book &ZBook [skip; str: skip]
	name string
	url string
	reset bool
	pull bool
	gitrepokey string
}

[params]
pub struct ZBookCollectionArgs {
pub mut:
	name string
	url string
	reset bool
	pull bool
}



pub fn (mut self ZBookCollection) get()!{

	println(" - zola collection get: $self.url")
	mut gs:=self.book.books.gitstructure
	mut locator := gs.locator_new(self.url)!
	mut repo := gs.repo_get(locator: locator,reset:self.reset,pull:self.pull)!
	self.book.books.gitrepos[repo.key()] = repo
	
	mut srcpath:=locator.path_on_fs()!

	
	println(" - zola collection: $srcpath")


}
