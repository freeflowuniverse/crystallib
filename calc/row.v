module calc

[heap]
pub struct Row {
pub mut:
	name          string
	alias         string
	description   string
	cells         []Cell
	sheet         &Sheet           [skip; str: skip]
	aggregatetype RowAggregateType
	reprtype      ReprType // how to represent it
	tags          string
	subgroup      string
}

// pub enum RowType{
// 	cur
// 	integer
// 	float
// }

pub enum RowAggregateType {
	unknown
	sum
	avg
	max
	min
}

[params]
pub struct RowNewParams {
pub mut:
	name          string
	growth        string
	aggregatetype RowAggregateType
	tags          string
	descr         string
	subgroup      string
	extrapolate   bool = true
}

// get a row with a certain name
// you can use the smart extrapolate function to populate the row
// params:
// 	name string
// 	growth string (this is input for the extrapolate function)
//  aggregatetype e.g. sum,avg,max,min  is used to go from months to e.g. year or quarter
//  tags []string e.g. ["hr","hrdev"] attach a tag to a row, can be used later to group
// smart exptrapolation is 3:2,10:5 means month 3 we start with 2, it grows to 5 on month 10
pub fn (mut s Sheet) row_new(args_ RowNewParams) !&Row {
	mut args := args_
	if args.aggregatetype == .unknown {
		args.aggregatetype = .sum
	}
	name := args.name.to_lower()
	if name.trim_space() == '' {
		return error('name cannot be empty')
	}
	mut r := Row{
		sheet: &s
		name: name
		aggregatetype: args.aggregatetype
		tags: args.tags
		description: args.descr
		subgroup: args.subgroup
	}
	s.rows[name] = &r
	for _ in 0 .. s.nrcol {
		r.cells << Cell{
			row: &r
		}
	}
	assert r.cells.len == s.nrcol
	if args.growth.len > 0 {
		if args.extrapolate {
			r.extrapolate(args.growth)!
		} else {
			r.smartfill(args.growth)!
		}
	}
	return &r
}

pub fn (mut r Row) cell_get(colnr int) !&Cell {
	if colnr > r.cells.len {
		return error("Cannot find cell, the cell is out of bounds, the colnr:'${colnr}' is larger than nr of cells:'${r.cells.len}'")
	}
	return &r.cells[colnr]
}
