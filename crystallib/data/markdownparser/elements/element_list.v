module elements

@[heap]
pub struct List {
	DocBase
pub mut:
	cat            ListCat
	interlinespace int // nr of lines in between

	indentation int
	order_start ?int // the first list item order, if any
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

	self.parse()!
	self.content = ''
	self.processed = true
	return 1
}

fn (mut self List) parse() ! {
	/*
		iterate over lines:
			each line is parsed as a list item
			if list item conforms to last list settings:
				append to last list
			else create new list with list item settings and append to new list

		how does a list item conform to list settings:
			1- indentation: do they have the same indentation?
			2- ordering: are they both ordered?
	*/
	lines := self.content.trim(' \n').split('\n')
	mut line_index := 0
	for line_index < lines.len {
		list, next_index := parse_list_level(self.parent_doc_, line_index, lines)!
		line_index = next_index
		self.children << list
	}
}

fn parse_list_level(docparent ?&Doc, line_index int, lines []string) !(List, int) {
	mut list := List{
		type_name: 'list'
		parent_doc_: docparent
	}
	mut line := lines[line_index]

	mut list_item := ListItem{
		content: line
		type_name: 'listitem'
	}
	list_item.process()!

	list.indentation = list_item.calculate_indentation()
	list.order_start = list_item.order
	list.children << list_item

	mut is_group_ordered := list.order_start != none

	mut i := line_index + 1
	for i < lines.len {
		line = lines[i]
		mut li := ListItem{
			content: line
			type_name: 'listitem'
			parent_doc_: docparent
		}
		li.process()!

		is_li_ordered := li.order != none

		if li.calculate_indentation() > list.indentation {
			// create a child group
			child_group, next_index := parse_list_level(docparent, i, lines)!
			i = next_index
			list.children << child_group
			continue
		}

		if li.calculate_indentation() < list.indentation
			|| (li.calculate_indentation() == list.indentation && is_group_ordered != is_li_ordered) {
			// current group has ended
			return list, i
		}

		// this list item belongs to the current group
		list.children << li
		i++
	}

	return list, lines.len
}

pub fn (self List) markdown()! string {
	mut h := ''
	for _ in 0 .. self.indentation*4 {
		h += ' '
	}

	if order_start := self.order_start{
		return self.ordered_list_markdown(h, order_start)!
	}

	mut out := ''
	for child in self.children{
		if child is ListItem{
			out += '${h}- ${child.markdown()!}\n'
			continue
		}

		out += child.markdown()!
	}
	
	return out
}

fn (self List) ordered_list_markdown(indentation string, order_start int)! string{
	mut out , mut order := '', order_start
	for child in self.children{
		if child is ListItem{
			out += '${indentation}${order}. ${child.markdown()!}\n'
			order++
			continue
		}

		out += child.markdown()!
	}
	
	return out
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
