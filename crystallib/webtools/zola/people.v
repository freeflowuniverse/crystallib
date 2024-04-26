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
	page_path     string
	biography     string
	image         ?&doctree.File
	page          ?&doctree.Page
	description   string
	organizations []string
	categories    []string
	memberships   []string
	countries     []string
	cities        []string
}
