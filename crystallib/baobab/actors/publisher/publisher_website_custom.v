module publisher

import freeflowuniverse.crystallib.webtools.zola
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.servers.caddy
import freeflowuniverse.crystallib.core.base

pub struct PublishWebsite {
	website string
	domain string
}

pub fn (mut p Publisher[Config]) publish_website(params PublishWebsite) ! {
	websites := p.list_website()!.filter(it.name == params.website)

	if websites.len > 1 {
		return error('multiple websites with name ${params.website} found.')
	} else if websites.len == 0 {
		return error('no websites with name ${params.website} found.')
	}

	website := websites[0]
	source_path := p.source_path(website)
	build_path := p.build_path(website)

	generate_website(website, source_path)!
	build_website(source_path, build_path)!
	p.serve_website(build_path, params.domain)!

	mut c := base.context()!
	mut r := c.redis()!
	r.set('zola:${website.name}:publish', build_path)!
	r.expire('zola:${website.name}:publish', 3600 * 12)!
}

fn generate_website(w Website, source_path string) ! {
	mut site := match w.framework {
		.zola {w.to_zola_website()!}
		else {return}
	}
	site.path_build = pathlib.get(source_path)
	site.generate()!
}

fn build_website(source_path string, build_path string) ! {
	zola.build(source_path, build_path)!
}

fn (mut p Publisher[Config]) serve_website(build_path string, domain string) ! {
	// set up caddy
	mut c := caddy.get('')!
	mut caddyfile := caddy.CaddyFile {}
	caddyfile.add_file_server(
		root: build_path
		domain: domain
	)!
	c.set_caddyfile(caddyfile)!
	c.start()!
}

fn (w Website) to_zola_website() !zola.ZolaSite {
	mut zola_site := zola.ZolaSite {
		url: ''
		name: w.name
		title: w.name
		description: w.description
	}

	for p in w.pages {
		zola_site.page_add(
			name: p.name
			collection: p.source.all_before(':')
			file: p.source.all_after(':')
			template: p.template
		)!
	}
	for s in w.sections {
		zola_site.add_section(s.to_zola_section())!
	}
	return zola_site
}

fn (s Section) to_zola_section() zola.Section {
	return zola.Section {
		name: s.name
		title: s.title
		// pages: s.pages.map(it.to_zola_page())
	}
}

// returns the source path of a website
fn (mut p Publisher[Config]) source_path(website Website) string {
	config := p.config() or {panic(err)}
	return '${config.source_path}/${website.name}'
}

// returns the build path of a website
fn (mut p Publisher[Config]) build_path(website Website) string {
	config := p.config() or {panic(err)}
	return '${config.build_path}/${website.name}'
}