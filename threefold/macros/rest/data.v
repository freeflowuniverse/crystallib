module rest

import os
import yaml
import json

pub struct DataLoader {
pub:
	base_path string
}

const image_fields = ['logo', 'image']

pub fn new_data_loader(base_path string) &DataLoader {
	return &DataLoader{
		base_path: base_path
	}
}

fn (mut d DataLoader) get_content(path string) ?(string, string) {
	mut lines := os.read_lines(path)?

	metadata_start := '---'
	mut metadata := ''
	mut found := 0
	mut current_line := 0

	for line in lines {
		current_line += 1

		if line.trim(' \n\t') == metadata_start {
			found += 1
		}

		if found == 2 {
			metadata = lines[0..current_line].join('\n')
			break
		}
	}

	return metadata, lines[current_line..lines.len].join('\n')
}

fn (mut d DataLoader) get_doc_type_name[T]() string {
	doc_type := T.name.to_lower()

	if doc_type.starts_with('rest.') {
		return doc_type[5..doc_type.len]
	}

	return doc_type
}

// TODO
fn (mut d DataLoader) resolve_links[T](mut document T) {
	// $for field in T.fields {
	// 	if field.name in ImageFields {
	// 		document.$(field.name) = $(field.name) // resolve_link()
	// 	}

	// 	if field.name == ContentField {
	// 		// resolve macros in content...etc?
	// 		document.$(field.name) = $(field.name) // process_content()
	// 	}
	// }
}

pub fn (mut d DataLoader) list[T](page int, page_count int) ?[]T {
	doc_type := d.get_doc_type_name[T]()
	path := os.join_path(d.base_path, doc_type)
	if !os.exists(path) {
		return error("cannot find documents at '${path}'")
	}

	ids := os.ls(path)?

	mut start := 0
	mut end := 0

	if page <= 0 {
		start = 1
	} else {
		start = page
	}

	if page_count <= 0 {
		end = ids.len - 1
	} else {
		end = page * page_count - 1
	}

	mut result := []T{}
	for id in ids[start..end] {
		mut document := d.get[T](id) or {
			println("error loading document of '${id}': ${err}")
			continue
		}
		document.id = id
		result << document
	}

	return result
}

pub fn (mut d DataLoader) get[T](id string) ?T {
	doc_type := d.get_doc_type_name[T]()
	path := os.join_path(d.base_path, doc_type, id)

	if !os.exists(path) {
		return error("cannot find document at '${path}'")
	}

	md_files := os.walk_ext(path, '.md')
	if md_files.len < 1 {
		return error("cannot find any markdown fils at '${path}'")
	}

	metadata, content := d.get_content(md_files[0])?
	json_str := yaml.yaml_to_json(metadata, replace_tags: false, debug: 0)?

	mut document := json.decode(T, json_str)?
	$if T is WithContent {
		document.content = content
	}
	return document
}

pub fn (mut d DataLoader) get_file[T](id string, filename string) ?string {
	doc_type := d.get_doc_type_name[T]()
	path := os.join_path(d.base_path, doc_type, id, filename)
	if !os.exists(path) {
		return error("cannot find file at '${path}'")
	}
	return os.read_file(path)
}
