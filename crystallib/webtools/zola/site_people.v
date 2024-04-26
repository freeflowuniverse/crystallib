module zola

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.doctree
import freeflowuniverse.crystallib.core.texttools

@[params]
pub struct PeopleAddArgs {
	Section
}

// adds a people section to the zola site
pub fn (mut site ZolaSite) people_add(args PeopleAddArgs) ! {
	people_section := Section{
		...args.Section
		name: 'people'
		title: if args.title != '' { args.title } else { 'People' }
		sort_by: if args.sort_by != .@none { args.sort_by } else { .weight }
		template: if args.template != '' { args.template } else { 'layouts/people.html' }
		page_template: if args.page_template != '' {
			args.page_template
		} else {
			'partials/personCard.html'
		}
		paginate_by: if args.paginate_by != 0 { args.paginate_by } else { 4 }
	}
	site.add_section(people_section)!
}

pub struct PersonAddArgs {
mut:
	name       string
	page       string
	collection string
	file       string
	image      string
	pointer    string
}

pub fn (mut site ZolaSite) person_add(args PersonAddArgs) ! {
	person := site.get_person(args)!

	if 'people' !in site.sections {
		site.people_add()!
	}

	mut page := site.tree.page_get(person.page_path)!

	image := person.image or { return error('Person must have an image') }

	person_page := new_page(
		name: person.cid
		Page: page
		title: person.name
		description: person.description
		taxonomies: {
			'people':      [person.cid]
			'memberships': person.memberships
			'categories':  person.categories
		}
		// Page: page
		extra: {
			'imgPath': image.file_name()
		}
		document: page.doc()!
		assets: [image.path]
	)!

	site.sections['people'].page_add(person_page)!
}

fn (site ZolaSite) get_person(args_ PersonAddArgs) !Person {
	if args_.pointer == '' && (args_.collection == '' || args_.page == '') {
		return error('Either pointer or post collection and page must be specified in order to add post')
	}

	mut args := args_
	if args.collection == '' {
		args.collection = args.pointer.split(':')[0]
	}

	// check collection exists
	_ = site.tree.collection_get(args.collection) or {
		return error('Collection ${args.collection} not found.')
	}

	if args.pointer == '' {
		args.pointer = '${args.collection}:${args.name}'
	}

	mut page := site.tree.page_get(args.pointer) or { return err }

	actions := page.doc()!.actions()

	person_definitions := actions.filter(it.name == 'person_define')
	if person_definitions.len == 0 {
		return error('specified file does not include a person definition.')
	}
	if person_definitions.len > 1 {
		return error('specified file includes multiple person definitions')
	}

	definition := person_definitions[0]
	name := definition.params.get_default('name', '')!
	image_ := definition.params.get_default('image_path', '')!
	mut person := Person{
		name: name
		cid: definition.params.get_default('cid', '')!
		description: definition.params.get_default('description', '')!
		organizations: definition.params.get_list_default('organizations', [])!
		biography: definition.params.get_default('bio', '')!
		page_path: definition.params.get_default('page_path', '')!
	}

	if person.cid == '' {
		return error('persons cid cant be empty')
	}

	page_ := definition.params.get_default('page_path', '')!
	// add image and page to article if they exist
	if page_ != '' {
		person = Person{
			...person
			page: site.tree.page_get(page_) or { return err }
		}
	}

	// // add image and page to person if they exist
	if image_ != '' {
		person = Person{
			...person
			image: site.tree.image_get('${args.collection}:${image_}') or { return err }
		}
	}

	return person
}



pub fn (mut site ZolaSite) person_add(args BlogAddArgs) ! {
	site.tree.process_includes()!
	_ = site.tree.collection_get(args.collection) or {
		println(err)
		return err
	}
	mut page := site.tree.page_get('${args.collection}:${args.file}') or {
		println(err)
		return err
	}

	mut people_index := pathlib.get_file(
		path: '${site.path_build.path}/content/people/_index.md'
	)!
	if !people_index.exists() {
		people_index.write('---
title: "Our People"
paginate_by: 4
sort_by: "weight"
template: "layouts/people.html"
page_template: "partials/personCard.html"
insert_anchor_links: "left"
description: "Our team brings together +30 years of experience in cloud automation, Internet storage, and infrastructure services. We are a passionate group on a collective mission to improve the planet’s situation and benefit the people around us."
---')!
	}

	people_dir := pathlib.get_dir(
		path: '${site.path_build.path}/content/people'
		create: true
	)!
	fixed_name := '${texttools.name_fix(args.name)}'
	person_dir := pathlib.get_dir(
		path: '${people_dir.path}/${fixed_name}'
		create: true
	)!
	page.export(dest: '${person_dir.path}/index.md')!
	site.blog.posts[args.name] = page.doc()!
}
