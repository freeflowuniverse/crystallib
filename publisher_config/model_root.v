module publisher_config

import os
// import despiegk.crystallib.process

// the main config file as used for the publisher
[heap]
pub struct ConfigRoot {
pub mut:
	root    string
	sites   []SiteConfig
	nodejs  NodejsConfig
	publish PublishConfig
	// web_hostnames bool
	staticfiles map[string]string
}

pub fn (mut config ConfigRoot) name_web_get(domain string) ?string {
	for s in config.sites {
		if domain in s.domains {
			return s.shortname
		}
	}
	return error('Cannot find wiki site with domain: $domain')
}

pub fn (mut cfg ConfigRoot) nodejs_check() {
	if !os.exists(cfg.nodejs.path) {
		println("ERROR\ncannot find nodejs, reinstall using 'publishtools install -r'")
		exit(1)
	}
}
