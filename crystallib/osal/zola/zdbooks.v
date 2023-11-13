module zola

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.zola
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.data.ourtime

[heap]
pub struct ZBooks {
pub mut:
	books []&ZBook
	path pathlib.Path
	gitrepos map[string]gittools.GitRepo
	coderoot string
	gitstructure gittools.GitStructure

}

[params]
pub struct ZBooksArgs {
pub mut:
	path string [required]
	coderoot string
	install bool = true
}


pub fn new(args ZBooksArgs)!ZBooks{
	if args.install{
		zola.install()!
	}	
	mut gs := gittools.get(coderoot:args.coderoot)!
	mut books:=ZBooks{
		path:pathlib.get_dir(path:args.path,create:true)!
		coderoot:args.coderoot
		gitstructure: gs
	}
	return books
}


pub fn (mut self ZBooks) check()!{
	mut repos_changed:=[]string{}
	for key,repo_ in self.gitrepos{
		mut repo:=repo_
		if repo.need_pull()!{
			repo.pull_reset()!
			repos_changed << key
		}
	}
	//now we know which repo's changed
	for key in repos_changed{
		for mut book in self.books{
			mut changed:=false
			if book.gitrepokey == key{
				changed=true
			}
			for collection in book.collections{
				if collection.gitrepokey == key{
					changed=true
				}
			}
			if changed{
				book.generate()!
			}
		}
	}
}


[params]
pub struct WatchArgs {
pub mut:
	period int = 300 //5 min default
}
pub fn (mut self ZBooks) watch(args WatchArgs){
	mut t:=ourtime.now()
	mut last:=i64(0)
	for {		
		t.now()
		if t.unix_time() > last + args.period{
			println(" - will try to check the zolas")
			self.check() or {" - ERROR: couldn't check the repo's.\n$err"}
		}
		last=t.unix_time()
	}

}
