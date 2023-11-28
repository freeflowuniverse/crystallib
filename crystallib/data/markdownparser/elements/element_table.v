module elements
import regex

[heap]
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
	cells  []string
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


pub fn (self Table) markdown() string {
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

pub fn (mut self Table) html() string {
	// TODO: implement html 
	panic("implement")
}

@[params]
pub struct TableNewArgs {
	ElementNewArgs
}


//get all relevant info out of table
pub fn (mut self Table) parse() ! {

	rows := self.content.split_into_lines()

	if rows.len<3{
		return error("table needs to have 3 rows at least.\n$self")
	}

	re_header_row := regex.regex_opt('^:?-+:?$') or { return error("regex doesn't work") }

	header := rows[0].trim('|').split('|').map(it.trim(' \t'))
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

	for line in rows[2..] {
		columns := line.trim('| ').split('|')
		mut row := Row{}
		if columns.len !=  self.num_columns{
			return error("wrongly formatted row.\n$self\n$line")
		}
		for cell in columns {
			row.cells << cell.trim_space()
		}
		self.rows << row
	}

}

