module playcmds

import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.webtools.zola
// import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.play

struct WebsiteItem {
mut:
	name string
	site ?&zola.ZolaSite
}

pub fn play_zola(mut session play.Session) ! {
	mut coderoot := ''
	mut buildroot := ''
	mut publishroot := ''
	mut install := true
	mut reset := false
	mut config_actions := session.plbook.find(filter: 'websites:configure')!
	if config_actions.len > 1 {
		return error('can only have 1 config action for websites')
	} else if config_actions.len == 1 {
		mut p := config_actions[0].params
		buildroot = p.get_default('buildroot', '')!
		publishroot = p.get_default('publishroot', '')!
		coderoot = p.get_default('coderoot', '')!
		install = p.get_default_true('install')
		reset = p.get_default_false('reset')
		config_actions[0].done = true
	}
	mut websites := zola.new(
		path_build: buildroot
		path_publish: publishroot
		install: install
		reset: reset
	)!

	mut ws := WebsiteItem{}

	for mut action in session.plbook.find(filter: 'website.')! {
		if action.name == 'define' {
			console.print_debug('website.define')
			mut p := action.params
			ws.name = p.get('name')!
			title := p.get_default('title', '')!
			description := p.get_default('description', '')!
			ws.site = websites.new(name: ws.name, title: title, description: description)!
		} else if action.name == 'template_add' {
			console.print_debug('website.template_add')
			mut p := action.params
			url := p.get_default('url', '')!
			path := p.get_default('path', '')!
			mut site_ := ws.site or {
				return error("can't find website for template_add, should have been defined before with !!website.define")
			}

			site_.template_add(url: url, path: path)!
		} else if action.name == 'content_add' {
			console.print_debug('website.content_add')
			mut p := action.params
			url := p.get_default('url', '')!
			path := p.get_default('path', '')!
			mut site_ := ws.site or {
				return error("can't find website for content_add, should have been defined before with !!website.define")
			}

			site_.content_add(url: url, path: path)!
		} else if action.name == 'doctree_add' {
			console.print_debug('website.doctree_add')
			mut p := action.params
			url := p.get_default('url', '')!
			path := p.get_default('path', '')!
			mut site_ := ws.site or {
				return error("can't find website for doctree_add, should have been defined before with !!website.define")
			}

			site_.doctree_add(url: url, path: path)!

			// }else if  action.name=="pull"{
			// 	mut site_:=ws.site or { return error("can't find website for pull, should have been defined before with !!website.define")}
			// 	site_.pull()!
		} else if action.name == 'generate' {
			mut site_ := ws.site or {
				return error("can't find website for generate, should have been defined before with !!website.define")
			}

			site_.generate()!
			site_.serve()!
		} else {
			return error("Cannot find right action for website. Found '${action.name}' which is a non understood action for !!website.")
		}
		action.done = true
	}
}
