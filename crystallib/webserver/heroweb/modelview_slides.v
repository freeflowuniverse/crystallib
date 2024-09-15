module heroweb

import freeflowuniverse.crystallib.core.playbook

struct Slide {
mut:
	name  string //is the filename
	title string
	notes string
}

struct SlidesViewData {
mut:
	name  string
	title string
	slides []Slide
	path   string
}

pub fn (mut s SlidesViewData) add_slide(slide Slide) {
	s.slides << slide
}

pub fn (s SlidesViewData) get_slide(name string) ?Slide {
	for slide in s.slides {
		if slide.name == name {
			return slide
		}
	}
	return none
}

fn play_slides(mut plbook playbook.PlayBook) !SlidesViewData {
    mut slides_data := SlidesViewData{}
    
    // Find and process the slides.define action
    define_actions := plbook.find(filter: 'slides.define')!
    if define_actions.len > 0 {
        define_action := define_actions[0]
        mut p := define_action.params
        slides_data.name = p.get('name')!
        slides_data.title = p.get('title')!
        slides_data.path = p.get('path')!
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

    return slides_data
}

@[params]
pub struct SlidesViewParams {
pub mut:
	name  string
	title string
	path string
	heroscript string
}

pub fn slides_view_new(args_ SlidesViewParams) !SlidesViewData  {
	mut args:=args_
	if args.heroscript ==""{
		args.heroscript = $tmpl("templates/example_slides.md")
	}	
	mut plbook := playbook.new(text: args.heroscript)!
	mut svd := play_slides(mut plbook)!
	return svd
}

pub fn slides_demo()! {
	
	// Create Slides instance and parse the input
	mut slides := slides_view_new( name:'slides', title:'Slides', path:'')!

	// Example usage
	println('Total number of slides: ${slides.slides.len}')
	println('Name of the first slide: ${slides.slides[0].name}')
	println('Name of the last slide: ${slides.slides[slides.slides.len - 1].name}')

	// Print all slides with their titles (if available)
	for slide in slides.slides {
		if slide.title!= "" {
			println('Slide: ${slide.name}, Title: ${slide.title}')
		} else {
			println('Slide: ${slide.name}')
		}
	}

	// Example of getting a slide by name
	team_slide := slides.get_slide('worldrecords.png') or { Slide{} }
	if team_slide.name != '' {
		println('Found slide: ${team_slide.name}')
	} else {
		println('Slide not found')
	}



}