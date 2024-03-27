module zola

<<<<<<< HEAD
import toml
import freeflowuniverse.crystallib.core.pathlib
// see https://www.getzola.org/documentation/content/section/#front-matter

pub struct Section {
	SectionFrontMatter
	name string
mut:
	pages []ZolaPage @[skip; str: skip]
}

pub struct SectionFrontMatter {
=======
pub fn (mut site ZolaSite) add_section(section Section) ! {
	if site.sections.any(it.name == section.name) {
		return error('Section with name `${section.name}` already exists.')
	}
	site.sections << section
}

// see https://www.getzola.org/documentation/content/section/#front-matter
pub struct Section {
	name                string
	pages               []Page
>>>>>>> c09c2ea (zola fixes)
	title               string
	description         string
	draft               bool
	sort_by             SortBy
	weight              int
<<<<<<< HEAD
	template            string
=======
	template            string = 'section.html'
>>>>>>> c09c2ea (zola fixes)
	page_template       string
	paginate_by         int
	paginate_path       string = 'page'
	paginate_reversed   bool
	insert_anchor_links InsertAnchorLinks
	in_search_index     bool = true
	render              bool = true
	redirect_to         string
	transparent         bool
	aliases             []string
	generate_feed       bool
<<<<<<< HEAD
	// extra               map[string]Extra
}

pub fn (mut section Section) page_add(page_ ZolaPage) ! {
	// = "page.html"
	mut page := page_
	if section.sort_by == .order {
		page.weight = section.pages.len + 1
	}
	section.pages << page
}

pub fn (mut section Section) export(dest_dir string) ! {
	front_matter := section.SectionFrontMatter.markdown()

	mut section_file := pathlib.get_file(path: '${dest_dir}/_index.md')!
	section_file.write('+++\n${front_matter}\n+++')!

	for mut page in section.pages {
		page.export(dest_dir)!
	}
}

fn (s SectionFrontMatter) markdown() string {
	front_matter := toml.encode(s)
	mut lines := front_matter.split_into_lines()
	for i, mut line in lines {
		if line.starts_with('sort_by = ') {
			if s.sort_by == .order {
				line = 'sort_by = "weight"'
				continue
			}
			line = 'sort_by = "${s.sort_by}"'
		}
		if line.starts_with('insert_anchor_links = ') {
			if s.insert_anchor_links == .@none {
				line = ''
				continue
			}
			line = 'insert_anchor_links = ${s.insert_anchor_links}'
			continue
		} else if line.starts_with('redirect_to = ') {
			if s.redirect_to == '' {
				line = ''
				continue
			}
		}
	}
	return lines.filter(it != '').join_lines()
}
=======
	extra               map[string]string
}

>>>>>>> c09c2ea (zola fixes)

pub enum SortBy {
	@none
	date
	update_date
	title
	title_bytes
	weight
	slug
<<<<<<< HEAD
	order
=======
>>>>>>> c09c2ea (zola fixes)
}

pub enum InsertAnchorLinks {
	@none
	left
	right
	heading
}

pub struct Page {
	content     string
	title       string
	weight      int
	description string
	taxonomies  map[string][]string
<<<<<<< HEAD
	extra       map[string]Extra    @[skip; str: skip]
}

type Extra = []string | string
=======
	extra       map[string]Extra
}

type Extra = []string | int | map[string]string | string
>>>>>>> c09c2ea (zola fixes)
