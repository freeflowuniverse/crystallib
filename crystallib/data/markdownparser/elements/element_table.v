module elements

import regex

@[heap]
pub struct Table {
	DocBase
pub mut:
	num_columns int
	alignments  []Alignment
	header      []string
	rows        []Row
}

pub struct Row {
pub mut:
	cells []string
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

	self.processed = true
	return 1
}

pub fn (self Table) markdown() !string {
	mut out := '| ${self.header.join(' | ')} |\n'
	// TODO: default alignment row, currently if emtpy table doesnt render
	// TODO: should render and format nicely (so all columns have same width once rendering)
	alignment_row := self.alignments.map(match it {
		.left { ' :-- ' }
		.center { ' :-: ' }
		.right { ' --: ' }
	}).join('|')
	out += '|${alignment_row}|\n'
	for row in self.rows {
		out += '| ${row.cells.join(' | ')} |\n'
	}
	return '${out}\n'
}

pub fn (self Table) pug() !string {
	return error("cannot return pug, not implemented")
}


pub fn (self Table) html() !string {
	// TODO: implement html
	panic('implement')
}

// get all relevant info out of table
pub fn (mut self Table) parse() ! {
	rows := self.content.split_into_lines()

	if rows.len < 3 {
		return error('table needs to have 3 rows at least.\n${self}')
	}

	re_header_row := regex.regex_opt('^:?-+:?$') or { return error("regex doesn't work") }

	mut header := rows[0].trim_space().split('|').map(it.trim(' \t'))
	header.delete_last()
	header.delete(0)

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
	self.header = header
	self.alignments = alignments

	for mut line in rows[2..] {
		mut columns := line.trim_space().split('|')
		if columns.len<2{
			return error('wrongly formatted row.\n${self}\n${line}')
		}
		columns.delete_last()
		columns.delete(0)

		// println(columns)
		// panic('panic.\n${self}\n${line}')

		mut row := Row{}
		if columns.len != self.num_columns {
			return error('wrongly formatted row.\n${self}\n${line}')
		}
		for cell in columns {
			row.cells << cell.trim_space()
		}
		self.rows << row
	}
}
