
module heroweb

import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.ui.console

pub fn (mut db WebDB) play_infopointers(mut plbook playbook.PlayBook) ! {

	console.print_stdout(plbook.str())

	webdb_actions5 := plbook.find(filter: 'webdb.infopointer_add')!

	mut gs := gittools.get()!

	for action in webdb_actions5 {

			hero_url:=action.params.get_default('hero_url', '')!
			mut hero_path:=action.params.get_default('hero_path', '')!
			hero_url_pull:=action.params.get_default_false('hero_url_pull')
			hero_url_reset:=action.params.get_default_false('hero_url_reset')

			if hero_url.len > 0 {
				hero_path = gs.code_get(
					pull: hero_url_pull
					reset: hero_url_reset
					url: hero_url
					reload: true
				)!
			}


			content_url:=action.params.get_default('content_url', '')!
			mut content_path:=action.params.get_default('content_path', '')!
			content_url_pull:=action.params.get_default_false('content_url_pull')
			content_url_reset:=action.params.get_default_false('content_url_reset')

			if content_url.len > 0 {
				content_path = gs.code_get(
					pull: content_url_pull
					reset: content_url_reset
					url: content_url
					reload: true
				)!
			}


			cat:=action.params.get_default('cat', '')!

			cat_type := match cat {
				'html' { InfoType.html }
				'slides' {  InfoType.slides }
				'pdf' { InfoType.pdf }
				'wiki' { InfoType.wiki }
				'website' { InfoType.website }
				else { 
					println('Invalid category')
					// Handle the error or set a default value
					InfoType.html // Default to html, for example
				}
			}			

	        db.infopointer_add(
	            name: action.params.get_default('name', '')!
	            path_content: content_path
				path_heroscript: hero_path
				cat: cat_type
	            acl: action.params.get_list('acl')!
	            tags: action.params.get_list_default('tags', [])!
	            description: action.params.get_default('description', '')!
	            expiration: action.params.get_default('expiration', '')!
	        ) or { return error('Failed to add InfoPointer: ${err}') }
	}
	

}
