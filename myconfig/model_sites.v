module myconfig

import os

pub struct SiteConfig {
pub mut:
	name      string
	url       string
	branch    string
	pull      bool // if set will pull but not reset
	reset     bool // if set will reset & pull, reset means remove changes
	cat       SiteCat
	shortname string
	path_code string
	domains   []string
	descr     string
}

pub enum SiteCat {
	wiki
	data
	web
}

pub fn (mut site SiteConfig) reponame() string {
	mut name2 := os.base(site.url)
	if name2.ends_with('.git') {
		name2 = name2[..name2.len - 4]
	}
	return name2
}

pub fn (config ConfigRoot) site_get(name string) ?SiteConfig {
	for site in config.sites {
		// println(" >> $site.name ${name.to_lower()}")
		if site.name.to_lower() == name.to_lower() {
			return site
		}
		if site.shortname.to_lower() == name.to_lower() {
			return site
		}
	}
	return error('Cannot find wiki site with name: $name')
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
			if site.shortname.to_lower() == name2 {
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
			if site.shortname.to_lower() == name2 {
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
		path := site.path_code
		if path == '' {
			continue
			// panic('we did not find site: $site, was the site downloaded?')
		}
		if os.exists(path) {
			sites << site
		}
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
		if shortname == s.shortname && s.cat == cat {
			return s.domains[0]
		}
	}
	return error('Cannot find $cat site with shortname: $shortname')
}
