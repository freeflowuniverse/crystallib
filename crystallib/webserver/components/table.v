module components

pub struct Row {
pub:
	cells []Cell
}

pub struct Cell {
pub:
	content string
}

pub struct Table {
pub:
	headers []string
	rows []Row
}

pub fn (table Table) html() string {
	headers := table.headers.map('<th>${it}</th>').join('')
	rows := table.rows.map(it.html()).join('\n')
	return '<table id="table">\n\t<thead>\n\t\t<tr>${headers}</tr>\n\t</thead>\n\t<tbody>\n${rows}\n\t</tbody>\n</table>'
}

pub fn (component Row) html() string {
	return "<tr>\n${component.cells.map(it.html()).join('\n')}\n</tr>"
}

pub fn (component Cell) html() string {
    return "<td>${component.content}</td>"
}