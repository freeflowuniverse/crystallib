module calc

pub struct Row{
pub mut:
	name string
	cells []Cell
	sheet &Sheet [str: skip]
	aggregatetype RowAggregateType
	tags []string
}

// pub enum RowType{
// 	cur
// 	integer
// 	float
// }

pub enum RowAggregateType{
	sum
	avg
	max
	min
}


pub struct RowNewParams{
pub mut:
	name string
	growth string
	aggregatetype RowAggregateType
	tags []string
}



//get a row with a certain name
// you can use the smart extrapolate function to populate the row
// params:
// 	name string
// 	growth string (this is input for the extrapolate function)
//  aggregatetype e.g. sum,avg,max,min  is used to go from months to e.g. year or quarter
//  tags []string e.g. ["hr","hrdev"] attach a tag to a row, can be used later to group
// smart exptrapolation is 3:2,10:5 means month 3 we start with 2, it grows to 5 on month 10
pub fn (mut s Sheet) row_new(args RowNewParams) !&Row {
	name:= args.name.to_lower()
	if name.trim_space()==""{
		return error("name cannot be empty")
	}
	mut r:=Row{sheet:&s,name:name,aggregatetype:args.aggregatetype,tags:args.tags}
	s.rows[name]=&r
	for _ in 0..s.nrcol{
		r.cells << Cell{row:&r}
	}
	assert r.cells.len == s.nrcol
	if args.growth.len>0{
		r.extrapolate(args.growth)!
	}
	return &r
}


pub fn (mut r Row) cell_get(colnr int) !&Cell {
	if colnr>r.cells.len {
		return error("Cannot find cell, the cell is out of bounds, the colnr:'$colnr' is larger than nr of cells:'${r.cells.len}'")
	}
	return &r.cells[colnr]
}


pub fn (mut r Row) add(name string, r2 Row) !&Row {
	mut row_result:=r.sheet.row_new(name:name,aggregatetype:r.aggregatetype)!
	assert row_result.cells.len == r.cells.len
	assert row_result.cells.len == r2.cells.len
	for x in 0.. r.sheet.nrcol{
		row_result.cells[x].val =  r.cells[x].val + r2.cells[x].val
		row_result.cells[x].empty = false
	}
	return row_result
}

pub fn (mut r Row) subtract(name string, r2 Row) !&Row {
	mut row_result:=r.sheet.row_new(name:name,aggregatetype:r.aggregatetype)!
	assert row_result.cells.len == r.cells.len
	assert row_result.cells.len == r2.cells.len
	for x in 0.. r.sheet.nrcol{
		row_result.cells[x].val =  r.cells[x].val - r2.cells[x].val
		row_result.cells[x].empty = false
	}
	return row_result
}

pub fn (mut r Row) multiply(name string, r2 Row) !&Row {
	mut row_result:=r.sheet.row_new(name:name,aggregatetype:r.aggregatetype)!
	assert row_result.cells.len == r.cells.len
	assert row_result.cells.len == r2.cells.len
	for x in 0.. r.sheet.nrcol{
		row_result.cells[x].val =  r.cells[x].val * r2.cells[x].val
		row_result.cells[x].empty = false
	}
	return row_result
}

pub fn (mut r Row) divide(name string, r2 Row) !&Row {
	mut row_result:=r.sheet.row_new(name:name,aggregatetype:r.aggregatetype)!
	assert row_result.cells.len == r.cells.len
	assert row_result.cells.len == r2.cells.len
	for x in 0.. r.sheet.nrcol{
		row_result.cells[x].val =  r.cells[x].val / r2.cells[x].val
		row_result.cells[x].empty = false
	}
	return row_result
}


pub fn (mut r Row) aggregate(name string) !&Row {
	mut row_result:=r.sheet.row_new(name:name,aggregatetype:r.aggregatetype)!
	assert row_result.cells.len == r.cells.len
	mut prevval:=0.0
	for x in 0.. r.sheet.nrcol{
		row_result.cells[x].val =  r.cells[x].val + prevval
		row_result.cells[x].empty = false
		prevval= row_result.cells[x].val
	}
	return row_result
}

