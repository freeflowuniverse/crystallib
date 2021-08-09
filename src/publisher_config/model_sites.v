module publisher_config

import os

pub struct SiteConfig {
pub mut:
	name   string
	prefix string // prefix as will be used on web, is optional
	// the site config is known by git_url or by fs_path
	git_url    string
	fs_path    string // path directly in the git repo or absolute on filesystem
	pull       bool   // if set will pull but not reset
	reset      bool   // if set will reset & pull, reset means remove changes
	cat        SiteCat
	path       string // path where the site is, the result of git operation or fs_path
	domains    []string
	descr      string
	acl        []SiteACE // access control list
	trackingid string    // Matomo/Analytics
	opengraph  OpenGraph
	state      SiteState
	// depends []SiteDependency
}

pub struct SiteDependency {
pub mut:
	git_url string
	path    string // path in the git repo as defined by the git_url
	fs_path string // path as on fs, can be local to the location of this config file
	branch  string
}

pub struct SiteACE {
pub mut:
	groups  []string
	users   []string
	rights  string = 'R' // default R today
	secrets []string // is list of secrets in stead of threefold connect which can give access
}

pub enum SiteCat {
	wiki
	data
	web
}

pub enum SiteState {
	init
	loaded
	processed
}

pub fn (mut site SiteConfig) reponame() string {
	if site.name == '' {
		site.name = os.base(site.git_url)
		if site.name.ends_with('.git') {
			site.name = site.name[..site.name.len - 4]
		}
	}
	return site.name
}

pub fn (config ConfigRoot) site_get(name string) ?SiteConfig {
	for site in config.sites {
		// println(" >> $site.name ${name.to_lower()}")
		if site.name.to_lower() == name.to_lower() {
			return site
		}
	}
	return error('Cannot find wiki site with name: $name')
}

pub fn (config ConfigRoot) site_exists(name string) bool {
	for site in config.sites {
		// println(" >> $site.name ${name.to_lower()}")
		if site.name.to_lower() == name.to_lower() {
			return true
		}
	}
	return false
}

// return using shortname or name (will first use shortname)
pub fn (mut config ConfigRoot) site_web_get(name string) ?SiteConfig {
	mut name2 := name.to_lower()
	if name2.starts_with('www_') {
		name2 = name2[4..]
	}
	if name2.starts_with('wiki_') {
		return error('cannot ask for wiki')
	}
	for site in config.sites {
		if site.cat == SiteCat.web {
			if site.name.to_lower() == name2 {
				return site
			}
			if site.name.to_lower() == name2 {
				return site
			}
		}
	}
	return error('Cannot find web site with name: $name')
}

// return using shortname or name (will first use shortname)
pub fn (mut config ConfigRoot) site_wiki_get(name string) ?SiteConfig {
	mut name2 := name.to_lower()
	if name2.starts_with('wiki_') {
		name2 = name2[5..]
	}
	if name2.starts_with('www_') {
		return error('cannot ask for www')
	}
	for site in config.sites {
		if site.cat == SiteCat.wiki {
			if site.name.to_lower() == name2 {
				return site
			}
			if site.name.to_lower() == name2 {
				return site
			}
		}
	}
	return error('Cannot find wiki site with name: $name')
}

// return using shortname or name (will first use shortname)
pub fn (mut config ConfigRoot) sites_get() []SiteConfig {
	mut sites := []SiteConfig{}
	for site in config.sites {
		sites << site
	}
	return sites
}

pub fn (config ConfigRoot) reponame(name string) ?string {
	mut site := config.site_get(name) or { return error('Cannot find site with configname: $name') }
	return site.reponame()
}

// get the domain name
pub fn (mut config ConfigRoot) domain_get(shortname string, cat SiteCat) ?string {
	for s in config.sites {
		if shortname == s.name && s.cat == cat {
			return s.domains[0]
		}
	}
	return error('Cannot find $cat site with shortname: $shortname')
}
