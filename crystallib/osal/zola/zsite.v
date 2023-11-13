module zola

// import freeflowuniverse.crystallib.osal
// import os
// import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.pathlib

[heap]
pub struct ZSite {
pub mut:
	sites &Zola [skip; str: skip]
	name string
	path_src pathlib.Path
	path_export pathlib.Path
	collections []ZSiteCollection
	gitrepokey string	
}


[params]
pub struct ZSiteArgs {
pub mut:
	name string [required]
	url string [required] //url of the summary.md file
}


pub fn (mut sites Zola) site_new(args ZSiteArgs)!&ZSite{

	path_src:="/tmp/zolas_builder/${args.name}" //where builds happen
	path_export:="${sites.path.path}/${args.name}"

	mut site:=ZSite{
		name:args.name
		path_src:pathlib.get_dir(path:path_src,create:true)!
		path_export:pathlib.get_dir(path:path_export,create:true)!
		sites:&sites
	}

	sites.sites<<&site

	return &site
}


pub fn (mut b ZSite) collection_add(args_ ZSiteCollectionArgs)!{
	mut args:=args_
	mut c:=ZSiteCollection{url:args.url,name:args.name,site:&b}
	c.get()!
	b.collections << c
}


pub fn (mut b ZSite) generate()!{
	println (" - site generate: ${b.name} on ${b.path_src}")
}

