module modelgenerator

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools

pub struct Model {
pub mut:
	root       bool // root model
	name       string
	name_lower string
	domain     string
	actor      string
	fields     []Field
	path       pathlib.Path
	comments   []string
	imports    []string
	inherit    string // to see which fields we need to add from inheritance
}

pub fn (mut m Model) field_find(name0 string) []Field {
	name := texttools.name_fix(name0)
	mut res := []Field{}
	for field in m.fields {
		if field.name_lower == name {
			res << field
		}
	}
	return res
}

pub fn (mut m Model) field_get(name0 string) !Field {
	mut res := m.field_find(name0)
	if res.len == 1 {
		return res[0]
	}
	return error('found ${res.len} nr of fields with name ${name0} in model, should have been one.')
}

pub fn (mut m Model) comments_str() string {
	if m.comments.len == 0 {
		return ''
	}
	mut out := []string{}
	for c in m.comments {
		out << '// ${c}'
	}
	return out.join('\n')
}
