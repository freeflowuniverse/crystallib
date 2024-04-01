module zola

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.doctree
import freeflowuniverse.crystallib.core.texttools

// People section for Zola site
pub struct People {
	Section
mut:
	persons map[string]Person
}

pub struct Person {
pub:
	cid           string         @[required]
	name          string
	image         ?&doctree.File
	page_path string
	biography     string
	description   string
	organizations []string
	categories    []string
	memberships   []string
	countries     []string
	cities        []string
}

@[params]
pub struct PeopleAddArgs {
	Section
}

// adds a people section to the zola site
fn (mut site ZolaSite) people_add(args PeopleAddArgs) ! {
	if people := site.people {
		return error('People section already exists in zola site')
	} else {
		site.people = People{}
	}
	people_section := Section{
		...args.Section
		name: if args.name != '' { args.name } else { 'people' }
		title: if args.title != '' { args.title } else { 'People' }
		sort_by: if args.sort_by != .@none { args.sort_by } else { .weight }
		template: if args.template != '' { args.template } else { 'layouts/people.html' }
		page_template: if args.page_template != '' { args.page_template } else { 'partials/personCard.html' }
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
	pointer string
}

pub fn (mut site ZolaSite) person_add(args PersonAddArgs) ! {
	person := site.get_person(args)!

	if 'people' !in site.sections {
		site.people_add()!
	}

	// image_path := if mut img := person.image {
	// 	// img.copy('${person_dir.path}/${img.file_name()}')!
	// 	img.file_name()
	// } else {
	// 	''
	// }

	// person_page := Page{
	// 	title: person.name
	// 	weight: 2
	// 	description: person.description
	// 	taxonomies: {
	// 		'people':      [person.cid]
	// 		'memberships': person.memberships
	// 		'categories':  person.categories
	// 	}
		// extra: {
		// 	'imgPath':       image_path
		// 	'organizations': person.organizations
		// 	'countries':     person.countries
		// 	'cities':        person.cities
		// 	'social_links':  ''
		// }
	// }

	mut page := site.tree.page_get(person.page_path) or {
		println(err)
		return err
	}

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
		extra: {'imgPath': 'test'}
		document: page.doc()!
	)!

	site.sections['people'].pages << person_page
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

	mut page := site.tree.page_get(args.pointer) or {
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
		cid: definition.params.get_default('cid', '')!
		description: definition.params.get_default('description', '')!
		organizations: definition.params.get_list_default('organizations', [])!
		biography: definition.params.get_default('bio', '')!
		page_path: definition.params.get_default('page_path', '')!
	}

	if person.cid == '' {
		return error('persons cid cant be empty')
	}

		// // add image and page to person if they exist
	if image_ != '' {
		person = Person{
			...person
			image: site.tree.image_get('${args.collection}:${image_}') or {
				println(err)
				return err
			}
		}
	}

	return person
}