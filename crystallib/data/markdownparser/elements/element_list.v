module elements

// has ListItems as children
import math

@[heap]
pub struct List {
	DocBase
pub mut:
	cat            ListCat
	interlinespace int // nr of lines in between
}

pub enum ListCat {
	bullet
	star
	nr
}

pub fn (mut self List) process() !int {
	if self.processed {
		return 0
	}

	self.parse()
	// pre := self.content.all_before('-')
	// self.depth = pre.len
	// self.content = self.content.all_after_first('- ')

	self.processed = true
	return 1
}

fn (mut self List) parse() {
	mut last_indent, mut last_order :=  0, 0
	for i, mut el in self.children {
		if mut el is ListItem {
			// all list children are list items
			el.indent = int(math.ceil(f64(el.depth)/4.0))

			if el.indent > last_indent {
				el.order = 1
			}

			if el.indent < last_indent {
				for j := i - 1; j >= 0; j-- {
					prev_element := self.children[j]
					if prev_element is ListItem && prev_element.indent == el.indent {
						last_order = prev_element.order
						break
					}
				}

				el.order = last_order + 1
			}

			if el.indent == last_indent {
				el.order = last_order + 1
			}

			last_indent = el.indent
			last_order = el.order
		}
	}
}

fn (mut self List) add_list_item(line string) {
	self.list_item_new(mut self.parent_doc_, line)
}

pub fn (self List) markdown()! string {
	return self.DocBase.markdown()!
}

pub fn (self List) pug() !string {
	return error("cannot return pug, not implemented")
}


pub fn (self List) html() !string {
	panic('implement')
	// return '<h${self.depth}>${self.content}</h${self.depth}>\n\n'
}

pub fn line_is_list(line string) bool {
	ltrim := line.trim_space()
	if ltrim == '' {
		return false
	}

	return is_list_item_start(ltrim)
}

pub fn is_list_item_start(line string) bool {
	if line.starts_with('- ') {
		return true
	}

	if line.starts_with('* ') {
		return true
	}

	if line.contains('.') {
		return txt_is_nr(line.all_before('.'))
	}

	return false
}

pub fn txt_is_nr(txt_ string) bool {
	txt := txt_.trim_space()
	for u in txt {
		if u > 47 && u < 58 { // see https://www.charset.org/utf-8
			continue
		}
		return false
	}
	return true
}
