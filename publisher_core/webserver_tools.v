module publishermod

// import nedpals.vex.router
// import nedpals.vex.server
import nedpals.vex.ctx
// import nedpals.vex.utils
import despiegk.crystallib.myconfig

// replace the text from domain name to localhost url
fn domain_replacer(req &ctx.Req, text_ string) string {
	mut text := text_
	// mut myconfig := (&MyContext(req.ctx)).config
	mut webnames := (&MyContext(req.ctx)).webnames

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
		if site.cat == myconfig.SiteCat.web {
			alias = site.shortname
		} else {
			alias = 'info/$site.shortname'
		}
		for domain in site.domains {
			ctx.webnames[domain] = alias
		}
	}
}
