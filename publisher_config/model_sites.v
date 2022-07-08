module publisher_config

import freeflowuniverse.crystallib.texttools

pub fn (config ConfigRoot) site_get(name2 string) ?SiteConfig {
	name := texttools.name_fix(name2)
	for site in config.sites {
		// println(" >> $site.name ${name.to_lower()}")
		if site.name == name {
			return site
		}
	}
	return error('Cannot find wiki site with name: $name')
}

pub fn (config ConfigRoot) site_exists(name2 string) bool {
	name := texttools.name_fix(name2)
	for site in config.sites {
		// println(" >> $site.name ${name.to_lower()}")
		if site.name == name {
			return true
		}
	}
	return false
}

// return using shortname or name (will first use shortname)
pub fn (config ConfigRoot) site_web_get(name string) ?SiteConfig {
	mut name2 := texttools.name_fix(name)
	if name2.starts_with('www_') {
		name2 = name2[4..]
	}
	if name2.starts_with('wiki_') {
		return error('cannot ask for wiki')
	}
	for site in config.sites {
		if site.cat == SiteCat.web {
			if site.name == name2 {
				return site
			}
			if site.name == name2 {
				return site
			}
		}
	}
	return error('Cannot find web site with name: $name')
}

// return using shortname or name (will first use shortname)
pub fn (config ConfigRoot) site_wiki_get(name string) ?SiteConfig {
	mut name2 := texttools.name_fix(name)
	if name2.starts_with('wiki_') {
		name2 = name2[5..]
	}
	if name2.starts_with('www_') {
		return error('cannot ask for www')
	}
	for site in config.sites {
		if site.cat == SiteCat.wiki {
			if site.name == name2 {
				return site
			}
			if site.name == name2 {
				return site
			}
		}
	}
	return error('Cannot find wiki site with name: $name')
}

// return sites, can specify one or more names
pub fn (config ConfigRoot) sites_get(names []string) []SiteConfig {
	mut names2 := []string{}
	for name in names {
		names2 << texttools.name_fix(name)
	}
	mut sites := []SiteConfig{}
	for site in config.sites {
		if texttools.name_fix(site.name) in names2 || names == [] {
			sites << site
		}
	}
	return sites
}

// return sites, can specify one or more names
pub fn (config ConfigRoot) sites_web_get(names []string) []SiteConfig {
	mut names2 := []string{}
	for name in names {
		names2 << texttools.name_fix(name)
	}
	mut sites := []SiteConfig{}
	for site in config.sites {
		if texttools.name_fix(site.name) in names2 || names == [] {
			if site.cat == .web {
				sites << site
			}
		}
	}
	return sites
}

// return sites, can specify one or more names
pub fn (config ConfigRoot) sites_wiki_get(names []string) []SiteConfig {
	mut names2 := []string{}
	for name in names {
		names2 << texttools.name_fix(name)
	}
	mut sites := []SiteConfig{}
	for site in config.sites {
		if texttools.name_fix(site.name) in names2 || names == [] {
			if site.cat == .wiki {
				sites << site
			}
		}
	}
	return sites
}

pub fn (config ConfigRoot) reponame(name string) ?string {
	mut site := config.site_get(name) or { return error('Cannot find site with configname: $name') }
	if site.repo.addr.name == '' {
		return error('name on repo cannot be empty')
	}
	return site.repo.addr.name
}

// get the domain name
pub fn (config ConfigRoot) domain_get(shortname string, cat SiteCat) ?string {
	for s in config.sites {
		if shortname == s.name && s.cat == cat {
			if s.domains.len > 0 {
				return s.domains[0]
			}
		}
	}
	// default domain
	return '${shortname}.domain'
}
