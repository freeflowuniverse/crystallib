module markdowndocs

pub enum Alignment as u8 {
	left
	center
	right
}

pub struct Table {
pub mut:
	content     string
	num_columns int
	alignments  []Alignment
	header      []string
	rows        [][]string
}

fn (mut o Table) process() ! {
	rows := o.content.split_into_lines()
	if rows.len > 2 {
		for row_string in rows[2..] {
			columns := row_string.trim('|').split('|')
			mut row := []string{}
			for i in 0 .. o.num_columns {
				if i < columns.len {
					row << columns[i].trim(' ')
				} else {
					row << ''
				}
			}
			o.rows << row
		}
	}
}

pub fn (o Table) wiki() string {
	mut out := '| ${o.header.join(' | ')} |\n'
	// TODO: default alignment row, currently if emtpy table doesnt render
	alignment_row := o.alignments.map(match it {
		.left { ' :-- ' }
		.center { ' :-: ' }
		.right { ' --: ' }
	}).join('|')
	out += '|${alignment_row}|\n'
	for row in o.rows {
		out += '| ${row.join(' | ')} |\n'
	}
	return '${out}\n'
}

fn (o Table) html() string {
	return o.wiki()
}

// fn (o Table) str() string {
// 	return '**** Table\n'
// }
