module slides

import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.develop.gittools
import os

pub fn play(mut plbook playbook.PlayBook) !SlidesViewData {
    mut slides_data := SlidesViewData{}
    
    // Find and process the slides.define action
    define_actions := plbook.find(filter: 'slides.define')!
    if define_actions.len > 0 {
        define_action := define_actions[0]
        mut p := define_action.params
        slides_data.name = p.get('name')!
        slides_data.title = p.get('title')!
    }

    // Find and process the slides.add_slide actions
    slide_actions := plbook.find(filter: 'slides.add_slide')!
    for action in slide_actions {
        mut p := action.params
        slide := Slide{
            name: p.get('name')!
            title: p.get('title')!
            notes: p.get('notes')!
        }
        slides_data.slides << slide
    }

    slide_actions_coll := plbook.find(filter: 'slides.add_collection')!
	mut gs := gittools.get()!

    for action in slide_actions_coll {
        mut p := action.params
		url:=p.get_default("url","")!
		pull:=p.get_default_false("pull")
		reset:=p.get_default_false("reset")
		mut path:=p.get_default("path","")!
		if url.len > 0 {
			path = gs.code_get(
				pull: pull
				reset: reset
				url: url
				reload: true
			)!
		}
		if ! os.exists(path){
			return error("can't find path ${path} for slides ${plbook}")
		}
		if ! (path in slides_data.paths){
			slides_data.paths<<path
		}	

    }

    return slides_data
}