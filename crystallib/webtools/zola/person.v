module zola

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.doctree
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
	cid           string         @[required]
	name          string
	image         ?&doctree.File
	page          ?&doctree.Page
	biography     string
	description   string
	organizations []string
	categories    []string
	memberships   []string
	countries     []string
	cities        []string
}

// adds a people section to the zola site
fn (mut site ZolaSite) people_add(args PeopleAddArgs) ! {
	if _ := site.people {
		return error('People section already exists in zola site')
	} else {
		site.people = People{}
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

	for _, mut person in people.persons {
		person.export(people_dir.path)!
	}
}

pub struct PersonAddArgs {
	name       string
	page       string
	collection string @[required]
	file       string @[required]
	image      string
}

pub fn (mut site ZolaSite) person_add(args PersonAddArgs) ! {
	if !site.sections.any(it.name == 'People') {
		site.add_section(
			name: 'People'
		)!
	}

	mut people := site.people or {
		site.people_add()!
		site.people or { panic('this should never happen') }
	}

	site.tree.process_includes()!
	mut page := site.tree.page_get(args.page) or {
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
	image_ := definition.params.get_default('image_path', '')!
	mut person := Person{
		name: name
		cid: texttools.name_fix(name)
		description: definition.params.get_default('description', '')!
		organizations: definition.params.get_list_default('organizations', [])!
		biography: definition.params.get_default('bio', '')!
	}

	collection := args.page.all_before(':')
	// // add image and page to person if they exist
	if image_ != '' {
		person = Person{
			...person
			image: site.tree.image_get('${collection}:${image_}') or {
				println(err)
				return err
			}
		}
	}

	people.persons[person.cid] = person
	site.people = people

	image_path := if mut img := person.image {
		// img.copy('${person_dir.path}/${img.file_name()}')!
		img.file_name()
	} else {
		''
	}

	person_page := Page{
		title: person.name
		weight: 2
		description: person.description
		taxonomies: {
			'people':      [person.cid]
			'memberships': person.memberships
			'categories':  person.categories
		}
		extra: {
			'imgPath':       image_path
			'organizations': person.organizations
			'countries':     person.countries
			'cities':        person.cities
			'social_links':  ''
		}
	}
}

pub fn (person Person) export(people_dir string) ! {
	println('exporting ${person}')
	person_dir := pathlib.get_dir(
		path: '${people_dir}/${person.cid}'
		create: true
	)!

	image_path := if mut img := person.image {
		img.copy('${person_dir.path}/${img.file_name()}')!
		img.file_name()
	} else {
		''
	}
	mut person_page := pathlib.get_file(
		path: '${person_dir.path}/index.md'
		create: true
	)!

	// content := if mut page := person.page {
	// 	page.doc()!.markdown()!
	// } else {''}
	content := person.biography

	person_page.write($tmpl('./templates/person.md'))!
}
