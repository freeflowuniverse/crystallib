module publisher_core

import freeflowuniverse.crystallib.publisher_config

// replace the text from domain name to localhost url
fn domain_replacer(webnames map[string]string, text_ string) string {
	mut text := text_

	for name, alias in webnames {
		if text.contains(name) {
			// println('2: $name $alias')
			text = text.replace('https://$name', 'http://localhost:9998/$alias')
			text = text.replace('http://$name', 'http://localhost:9998/$alias')
		}
	}

	return text
}

// init's the replacement instructions we need to do
fn (mut ctx MyContext) domain_replacer_init() {
	mut alias := ''
	for site in ctx.config.sites {
		if site.cat == publisher_config.SiteCat.web {
			alias = site.name
		} else {
			alias = 'info/$site.name'
		}
		for domain in site.domains {
			ctx.webnames[domain] = alias
		}
	}
}
