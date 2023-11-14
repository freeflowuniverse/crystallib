module zola

// import freeflowuniverse.crystallib.osal
// import os
// import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.pathlib
import os

[heap]
pub struct ZSite {
pub mut:
	sites       &Zola             [skip; str: skip]
	url         string // url of site repo
	name        string
	path_src    pathlib.Path
	path_export pathlib.Path
	collections []ZSiteCollection
	gitrepokey  string
}

[params]
pub struct ZSiteArgs {
pub mut:
	name  string [required]
	url   string [required] // url of the summary.md file
	reset bool
	pull  bool
}

pub fn (mut sites Zola) site_new(args ZSiteArgs) !&ZSite {
	path_src := '/tmp/zolas_builder/${args.name}' // where builds happen
	path_export := '${sites.path.path}/${args.name}'

	mut gs := sites.gitstructure
	mut locator := gs.locator_new(args.url)!
	mut repo := gs.repo_get(locator: locator, reset: args.reset, pull: args.pull)!
	sites.gitrepos[repo.key()] = repo
	mut path_site_dir := locator.path_on_fs()!

	os.mkdir_all('/tmp/mdbooks_build/${args.name}/src')!

	mut site := ZSite{
		name: args.name
		url: args.url
		path_src: path_site_dir
		path_export: pathlib.get_dir(path: path_export, create: true)!
		sites: &sites
		gitrepokey: repo.key()
	}
	sites.sites << &site

	return &site
}

pub fn (mut b ZSite) collection_add(args_ ZSiteCollectionArgs) ! {
	mut args := args_
	mut c := ZSiteCollection{
		url: args.url
		name: args.name
		site: &b
	}
	c.get()!
	b.collections << c
}

pub fn (mut b ZSite) generate() ! {
	println(' - site generate: ${b.name} on ${b.path_src}')
	println('bash ${b.path_src.path}/build.sh')
	os.execute('bash ${b.path_src.path}/build.sh')
	os.mv('${b.path_src.path}/public', b.path_export.path)!
}
