module zola

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
	title               string
	description         string
	draft               bool
	sort_by             SortBy
	weight              int
	template            string = 'section.html'
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
	extra               map[string]string
}


pub enum SortBy {
	@none
	date
	update_date
	title
	title_bytes
	weight
	slug
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
	extra       map[string]Extra
}

type Extra = []string | int | map[string]string | string
