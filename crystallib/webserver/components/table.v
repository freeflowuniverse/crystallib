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
	rows []Row
}

pub fn (component Row) html() string {
	return "<tr>\n${component.cells.map(it.html()).join('\n')}\n</tr>"
}

pub fn (component Cell) html() string {
    return "<td>${component.content}</td>"
}