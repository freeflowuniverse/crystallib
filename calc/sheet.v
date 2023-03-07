module calc

import freeflowuniverse.crystallib.currency

[heap]
pub struct Sheet{
pub mut:
	name string
	rows map[string]&Row
	nrcol int = 60
	params SheetParams
	currencies &currency.Currencies
	currency &currency.Currency
}

pub struct SheetParams{
pub mut:
	visualize_cur bool //if we want to show e.g. $44.4 in a cell or just 44.4
}


//find maximum length of a cell (as string representation for a colnr)
//0 is the first col
//the headers if used are never counted
pub fn (mut s Sheet) len_col_max(colnr int) !int {
	mut lmax:=0
	for _,mut row in s.rows{
		if row.cells.len>colnr{
			mut c:=row.cell_get(colnr)!
			ll := c.repr().len
			if ll>lmax {lmax=ll} 
		}
	}
	return lmax

}

[params]
struct ToYearArgs{
pub mut:
	name string
	rowfilter []string
}

//find all rows which have one of the tags
//aggregate (sum) them into one row
// returns a row with the result
// useful to e.g. make new row which makes sum of all salaries for e.g. devengineering tag (or more than 1 tag)
pub fn (mut s Sheet) group2row(name string, tags []string) !&Row {

	//TODO, implement

}


pub fn (mut s Sheet) toyear() !Sheet {
	if args.name==""{
		args.name=s.name"+_year"
	}
	//if rowfilter is not empty only put the rows in as specified and in order of specified
	//make a new sheet, copy all required properties
	//create new rows/cells where the toyear represent a year 
	//use the aggregation property, sum means we sum, avg means we make avg over the year, ...
	//the result is a new sheet in which we have only required rows and show per year

	//TODO, implement
	//TODO, make sure to set right nr of cols (/12)

}

pub fn (mut s Sheet) toquarter() !Sheet {
	if args.name==""{
		args.name=s.name"+_quarter"
	}
	//TODO, implement
	//TODO, make sure to set right nr of cols (/4)

}


//return array with same amount of items as cols in the rows
//
//for year we return Y1, Y2, ...
//for quarter we return Q1, Q2, ...
//for months we returm m1, m2, ...
pub fn (mut s Sheet) header() ![]string {
	//if col + 40 = months
	//if col + 10 = quarters
	//else is years

}


pub fn (mut s Sheet) json() !string {
	//export to nice json representation

}


//find row, report error if not found
pub fn (mut s Sheet) row_get(name string) !&Row {
	//TODO:

}


//find row, report error if not found
pub fn (mut s Sheet) cell_get(row string,col int) !&Cell {
	//TODO:

}
