module zola

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.doctree
import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.data.markdownparser.elements
import os
import freeflowuniverse.crystallib.core.texttools

// People section for Zola site
pub struct People {
mut:
	persons map[string]Person
}

@[params]
pub struct PeopleAddArgs {}

pub struct Person {
pub:
	id string [required]
	name string
	image ?&doctree.File
	page ?&doctree.Page
	biography string
	description string
}

// adds a people section to the zola site
fn (mut site ZolaSite) people_add(args PeopleAddArgs) ! {
	if people := site.people {
		return error('People section already exists in zola site')
	} else {
		site.people = People {}
	}
}

fn (mut people People) export(content_dir string) ! {
	people_dir := pathlib.get_dir(
		path: '${content_dir}/people'
		create: true
	)!

	mut people_index := pathlib.get_file(
		path: '${people_dir.path}/_index.md'
		create: true
	)!
	people_index.write($tmpl('./templates/people.md'))!

	for id, mut person in people.persons {
		person.export(people_dir.path)!
	}
} 

pub struct PersonAddArgs {
	name       string
	collection string @[required]
	file       string @[required]
	image      string
}

pub fn (mut site ZolaSite) person_add(args PersonAddArgs) ! {
	mut people := site.people or {
		site.people_add()!
		site.people or {panic('this should never happen')}
	}

	site.tree.process_includes()!
	_ = site.tree.collection_get(args.collection) or {
		println(err)
		return err
	}
	mut page := site.tree.page_get('${args.collection}:${args.file}') or {
		println(err)
		return err
	}

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
	page_ := definition.params.get_default('bio', '')!
	image_ := definition.params.get_default('image', '')!
	mut person := Person{
		id: texttools.name_fix(name)
		name: name
	}

	// add image and page to person if they exist
	if page_ != '' {
		person = Person{
			...person,
			page: site.tree.page_get('${args.collection}:${page_}') or {
				println(err)
				return err
			}
		}
	}
	if image_ != '' {
		person = Person{
			...person,
			image: site.tree.image_get('${args.collection}:${image_}') or {
				println(err)
				return err
			}
		}
	}

	people.persons[person.id] = person
	site.people = people
}

pub fn (person Person) export(people_dir string) ! {
	person_dir := pathlib.get_dir(
		path: '${people_dir}/${person.id}'
		create: true
	)!

	image_path := if mut img := person.image {
		img.copy('${person_dir.path}/${img.file_name()}')!
		img.file_name()
	} else {''}
	mut person_page := pathlib.get_file(
		path: '${person_dir.path}/index.md'
		create: true
	)!
	
	content := if mut page := person.page {
		page.doc()!.markdown()!
	} else {''}
	person_page.write($tmpl('./templates/person.md'))!
}