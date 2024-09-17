module elements

import regex
// import freeflowuniverse.crystallib.ui.console

@[heap]
pub struct Table {
	DocBase
pub mut:
	num_columns int
	alignments  []Alignment
	header      []&Paragraph
	rows        []Row
}

pub struct Row {
pub mut:
	cells []&Paragraph
}

pub enum Alignment as u8 {
	left
	center
	right
}

pub fn (mut self Table) process() !int {
	if self.processed {
		return 0
	}

	self.parse()!
	self.content = ''
	self.processed = true
	return 1
}

pub fn (self Table) header_markdown() !string {
	mut out := []string{}
	for h in self.header {
		out << h.markdown()!
	}

	return '| ${out.join(' | ')} |\n'
}

fn (self Row) markdown() !string {
	mut out := []string{}
	for c in self.cells {
		out << c.markdown()!
	}

	return '| ${out.join(' | ')} |\n'
}

pub fn (self Table) markdown() !string {
	mut out := self.header_markdown()!
	// TODO: default alignment row, currently if emtpy table doesnt render
	// TODO: should render and format nicely (so all columns have same width once rendering)
	alignment_row := self.alignments.map(match it {
		.left { ' :-- ' }
		.center { ' :-: ' }
		.right { ' --: ' }
	}).join('|')
	out += '|${alignment_row}|\n'
	for row in self.rows {
		out += row.markdown()!
	}
	return '${out}'
}

pub fn (self Table) pug() !string {
	return error('cannot return pug, not implemented')
}

pub fn (self Table) html() !string {
	// TODO: implement html
	panic('implement')
}

// get all relevant info out of table
pub fn (mut self Table) parse() ! {
	rows := self.content.split_into_lines()

	if rows.len < 2 {
		msg := 'table needs to have 2 rows at least.\n${self}'
		panic(msg)
		return error(msg)
	}

	re_header_row := regex.regex_opt('^:?-+:?$') or {
		return error("regex doesn't work for table parsing")
	}

	mut header := rows[0].trim_space().split('|').map(it.trim(' \t'))
	header.delete_last()
	header.delete(0)

	for h in header {
		mut paragraph := self.paragraph_new(mut self.parent_doc(), h)
		paragraph.process()!
		self.header << paragraph
	}

	second_row := rows[1].trim('|').split('|').map(it.trim(' \t')).filter(re_header_row.matches_string(it))

	mut alignments := []Alignment{}
	for cell in second_row {
		mut alignment := Alignment.left
		if cell[0] == 58 { // == ":"
			if cell[cell.len - 1] == 58 { // == ":"
				alignment = Alignment.center
			}
		} else if cell[cell.len - 1] == 58 { // == ":"
			alignment = Alignment.right
		}
		alignments << alignment
	}

	self.num_columns = header.len
	self.alignments = alignments

	for mut line in rows[2..] {
		mut columns := line.trim_space().split('|')
		if columns.len < 2 {
			return error('wrongly formatted row.\n${self}\n${line}')
		}
		columns.delete_last()
		columns.delete(0)

		// console.print_debug(columns)
		// panic('panic.\n${self}\n${line}')

		mut row := Row{}
		if columns.len != self.num_columns {
			return error('wrongly formatted row.\n${self}\n${line}')
		}
		for cell in columns {
			mut paragraph := self.paragraph_new(mut self.parent_doc(), cell.trim_space())
			paragraph.process()!
			row.cells << paragraph
		}
		self.rows << row
	}
}
