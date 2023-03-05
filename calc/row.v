module calc

pub struct Row{
pub mut:
	name string
	cells []Cell
	sheet &Sheet [str: skip]
}


pub fn (mut r Row) cell_get(colnr) !&Cell {
	if colnr>cells.len {
		return error("Cannot find cell, the cell is out of bounds, the colnr:'$colnr' is larger than nr of cells:'${cells.len}'")
	}
	return &r.cells[colnr]
}