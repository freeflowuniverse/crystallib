module elements

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

	self.parse()!
	// pre := self.content.all_before('-')
	// self.depth = pre.len
	// self.content = self.content.all_after_first('- ')

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
	lines := self.content.split('\n')
	mut line_index := 0
	for line_index < lines.len {
		group, next_index := parse_list_group(line_index, lines)!
		line_index = next_index
		self.children << group
	}
}

fn parse_list_group(line_index int, lines []string) !(ListGroup, int) {
	mut group := ListGroup{
		// trailing_lf: false
	}
	mut line := lines[line_index]

	mut list_item := ListItem{
		content: line
		type_name: 'listitem'
		// trailing_lf: false
	}
	list_item.process()!

	group.indentation = list_item.calculate_indentation()
	group.order_start = list_item.order
	group.children << list_item

	mut is_group_ordered := group.order_start != none

	mut i := line_index + 1
	for i < lines.len {
		line = lines[i]
		mut li := ListItem{
			content: line
			type_name: 'listitem'
			// trailing_lf: false
		}
		li.process()!

		is_li_ordered := li.order != none

		if li.calculate_indentation() > group.indentation {
			// create a child group
			child_group, next_index := parse_list_group(i, lines)!
			i = next_index
			group.children << child_group
			continue
		}

		if li.calculate_indentation() < group.indentation
			|| (li.calculate_indentation() == group.indentation && is_group_ordered != is_li_ordered) {
			// current group has ended
			return group, i
		}

		// this list item belongs to the current group
		group.children << li
		i++
	}

	return group, lines.len
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
