module mdbook

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools

@[heap]
pub struct Summary {
pub mut:
	items       []SummaryItem
	errors      []SummaryItem // means we found errors, so we need to add to summary
	addpages    []SummaryItem // means we found pages as links, so we need to add them to the summary
	collections []string
}

pub struct SummaryItem {
pub mut:
	level       int
	description string
	path        string
	collection  string
	pagename    string
}

pub fn (mut book MDBook) summary() !Summary {
	mut summary := Summary{}
	mut summary_path := pathlib.get_file(path: book.args.summary_path, create: false)!
	c := summary_path.read()!

	mut level := 0
	mut pre_last := ''

	for mut line in c.split_into_lines() {
		if !(line.trim_space().starts_with('-')) {
			continue
		}

		pre := line.all_before('-')
		if pre.len > pre_last.len {
			level += 1 // increase level
		} else if pre.len < pre_last.len {
			level -= 1
			if level < 0 {
				panic('bug, level should never be below 0')
			}
		}
		pre_last = pre

		line = line.trim_left(' -')

		// - [Dunia Yetu](dy_intro/dunia_yetu/dunia_yetu.md)
		//     - [About Us](dy_intro/dunia_yetu/about_us.md)

		if !line.starts_with('[') {
			book.error(msg: "syntax error in summary: '${line}', needs to start with [")
			continue
		}

		if !line.contains('](') {
			book.error(msg: "syntax error in summary: '${line}', needs to have ](")
			continue
		}

		description := line.all_after_first('[').all_before(']').trim_space()
		path := line.all_after_first('(').all_before_last(')').trim_space()

		if !path.contains('/') {
			book.error(
				msg: "syntax error in summary: '${line}', doesn't contain collectionname (is first element of path)"
			)
			continue
		}
		pagename := texttools.name_fix(path.all_after_last('/'))
		collection := texttools.name_fix(path.all_before('/'))

		if collection !in summary.collections {
			summary.collections << collection
		}

		mut path_collection_str := '${book.args.doctree_path}/${collection}'
		mut path_collection := pathlib.get_dir(path: path_collection_str, create: false) or {
			book.error(
				msg: "collection find error in summary: '${line}', can't find collection:${path_collection_str} "
			)
			continue
		}

		if !path_collection.file_exists(pagename) {
			book.error(
				msg: "page find error in summary: '${line}', can't find page: ${pagename} in collection:${path_collection_str}"
			)
			continue
		}

		summary.items << SummaryItem{
			level: level
			path: path
			description: description
			pagename: pagename
			collection: collection
		}
	}

	return summary
}

fn (mut self Summary) add_error_page(collectionname string, pagename string) {
	description := 'errors ${collectionname}'
	self.errors << SummaryItem{
		level: 2
		description: description
		pagename: pagename
		collection: collectionname
	}
}

fn (mut self Summary) add_page_additional(collectionname string, pagename string) {
	shortname := pagename.all_before_last('.').to_lower()
	description := '_${shortname}'
	self.addpages << SummaryItem{
		level: 2
		description: description
		pagename: pagename
		collection: collectionname
	}
}

pub fn (mut self Summary) str() string {
	mut out := []string{}

	for item in self.items {
		mut pre := ''
		for _ in 0 .. item.level {
			pre += '  '
		}
		out << '${pre}- [${item.description}](${item.collection}/${item.pagename})'
	}
	if self.errors.len > 0 || self.addpages.len > 0 {
		out << '- [_](additional/additional.md)'
	}
	if self.errors.len > 0 {
		out << '  - [Errors](additional/errors.md)'
		for item in self.errors {
			mut pre := ''
			for _ in 0 .. item.level {
				pre += '  '
			}
			out << '${pre}- [${item.description}](${item.collection}/${item.pagename})'
		}
	}
	if self.addpages.len > 0 {
		out << '    - [unlisted_pages](additional/pages.md)'
		for item in self.errors {
			mut pre := ''
			for _ in 0 .. item.level {
				pre += '  '
			}
			out << '${pre}- [${item.description}](${item.collection}/${item.pagename})'
		}
	}

	return out.join_lines()
}
