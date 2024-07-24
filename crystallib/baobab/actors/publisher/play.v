module publisher

import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.webtools.zola
import freeflowuniverse.crystallib.core.playbook

pub fn play(mut plbook playbook.PlayBook) ! {
	mut p := get('')!

	for mut action in plbook.find(filter: 'publisher.')! {
		match action.name {
			'define_website' { 
				mut actions := plbook.find(filter: 'publisher.website.')!
				p.play_define_website(mut action, mut actions)! 
			}
			'new_template' { p.new_template(action.params.decode[Template]()!)! }
			'new_collection' { p.new_collection(action.params.decode[Collection]()!)! }
			'publish_website' { p.publish_website(action.params.decode[PublishWebsite]()!)! }
			// 'protect_website' { p.protect_publication(action.params.decode[PublishWebsite]()!)! }
			else { return error("Cannot find right action for publisher. Found '${action.name}' which is a non understood action for !!publisher.") }
		}
		action.done = true
	}
}

pub fn (mut p Publisher[Config]) play_define_website(mut action playbook.Action, mut actions []&playbook.Action) ! {
	mut website := action.params.decode[Website]()!
	for mut a in actions {
		match a.name.trim_string_left('publisher.website.') {
			'add_section' { 
				section := a.params.decode[Section]()!
				p.website_add_section(mut website, section)! 
			}
			'add_page' {
				page := a.params.decode[Page]()!
				p.website_add_page(mut website, page)! 
			}
			// 'add_blog_section' { website.add_section(a.params.decode[Section]()!)! }
			// 'add_blog_page' { website.add_section() }
			// 'add_people_section' { website.add_section(a.params.decode[Section]()!)! }
			// 'add_people_page' { website.add_section() }
			// 'add_news_section' { website.add_news_section(a.params.decode[AddNewsSection]()!)! }
			// 'add_news_page' { website.add_news_section(a.params.decode[AddNewsSection]()!)! }
			else {}
		}
	}
	p.new_website(website)!
}