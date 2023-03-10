module calc

import freeflowuniverse.crystallib.currency

[heap]
pub struct Sheet {
pub mut:
	name       string
	rows       map[string]&Row
	nrcol      int = 60
	params     SheetParams
	currencies &currency.Currencies
	currency   &currency.Currency
}

pub struct SheetParams {
pub mut:
	visualize_cur bool // if we want to show e.g. $44.4 in a cell or just 44.4
}

// find maximum length of a cell (as string representation for a colnr)
// 0 is the first col
// the headers if used are never counted
pub fn (mut s Sheet) len_col_max(colnr int) !int {
	mut lmax := 0
	for _, mut row in s.rows {
		if row.cells.len > colnr {
			mut c := row.cell_get(colnr)!
			ll := c.repr().len
			if ll > lmax {
				lmax = ll
			}
		}
	}
	return lmax
}


// find all rows which have one of the tags
// aggregate (sum) them into one row
// returns a row with the result
// useful to e.g. make new row which makes sum of all salaries for e.g. devengineering tag (or more than 1 tag)
pub fn (mut s Sheet) group2row(name string, tags []string) !&Row {
	mut rowout:=s.row_new(name:name,growth:"1:0.0")!
	println(rowout)
	if true{panic('sdsds')}
	for _,row in s.rows{
		if tags.len>0{
			mut ok:=false
			for tag1 in row.tags{
				for tag2 in tags{
					if tag1.to_lower()==tag2.to_lower(){
						ok=true
					}
				}
			}
			if ok==false{
				continue
			}
		}
		mut x:=0
		for cell in row.cells{
			rowout.cells[x].val += cell.val
			x+=1
		}
	}
	println(rowout)
	if true{panic('sdsds')}	
	return rowout
}

[params]
struct ToYearQuarterArgs {
pub mut:
	name       string
	rowsfilter []string
	tagsfilter []string
	period_months int=12
}

//internal function used by to year and by to quarter
fn (mut s Sheet) tosmaller(args_ ToYearQuarterArgs) !Sheet {
	mut args:=args_
	if args.name == '' {
		args.name = s.name + '_year'
	}
	nrcol_new:=int(s.nrcol/args.period_months)
	if f64(nrcol_new)!= s.nrcol/args.period_months{
		//means we can't do it
		panic("is bug, can only be 4 or 12")
	}
	mut sheet_out:=sheet_new(name:args.name, nrcol:nrcol_new, visualize_cur:s.params.visualize_cur, curr:s.currency.name)!
	for _,row in s.rows{
		if args.rowsfilter.len>0 || args.tagsfilter.len>0 {
			mut ok:=false
			for tag1 in row.tags{
				for tag2 in args.tagsfilter{
					if tag1.to_lower()==tag2.to_lower(){
						ok=true
					}
				}
			}
			for name1 in args.rowsfilter{
				if name1.to_lower()==row.name.to_lower(){
					ok=true
				}
			}			
			if ok==false{
				continue
			}		
		}
		//means filter not specified or 
		mut rnew:=sheet_out.row_new(name:row.name,aggregatetype:row.aggregatetype,tags:row.tags,growth:"1:0.0")!	
		for x in 0..nrcol_new{
			mut newval:=0.0
			for xsub in 0..args.period_months{
				if row.aggregatetype == .sum || row.aggregatetype == .avg {
					newval+= rnew.cells[x+xsub].val
				}else if row.aggregatetype == .max{
					if rnew.cells[x+xsub].val > newval{
						newval=rnew.cells[x+xsub].val
					}
				}else if row.aggregatetype == .min{
				if rnew.cells[x+xsub].val < newval{
						newval=rnew.cells[x+xsub].val
					}
				}else{
					panic("not implemented")
				}
			}
			if row.aggregatetype == .sum || row.aggregatetype == .max || row.aggregatetype == .min{
				rnew.cells[x].val = newval
			}else{
				//avg
				rnew.cells[x].val = newval / args.period_months
			}			
			 
		}
		return sheet_out
	}
	return s
}

//make a copy of the sheet and aggregate on year
// params
//   name       string
//   rowsfilter []string
//   tagsfilter []string
// tags if set will see that there is at least one corresponding tag per row
// rawsfilter is list of names of rows which will be included
pub fn (mut s Sheet) toyear(args ToYearQuarterArgs) !Sheet {
	mut args2:=args
	args2.period_months = 12
	return s.tosmaller(args2)
}

//make a copy of the sheet and aggregate on quarter
// params
//   name       string
//   rowsfilter []string
//   tagsfilter []string
// tags if set will see that there is at least one corresponding tag per row
// rawsfilter is list of names of rows which will be included
pub fn (mut s Sheet) toquarter(args ToYearQuarterArgs) !Sheet {
	mut args2:=args
	args2.period_months = 4
	return s.tosmaller(args2)
}

// return array with same amount of items as cols in the rows
//
// for year we return Y1, Y2, ...
// for quarter we return Q1, Q2, ...
// for months we returm m1, m2, ...
pub fn (mut s Sheet) header() ![]string {
	// if col + 40 = months	
	if s.nrcol>40{
		mut res:=[]string{}
		for x in 1..s.nrcol+1{
			res << "M${x}"
		}
		return res
	}
	// if col + 10 = quarters
	if s.nrcol>10{
		mut res:=[]string{}
		for x in 1..s.nrcol+1{
			res << "Q${x}"
		}
		return res
	}

	// else is years
	mut res:=[]string{}
	for x in 1..s.nrcol+1{
		res << "Y${x}"
	}
	return res
}

pub fn (mut s Sheet) json() !string {
	// export to nice json representation (TODO)
	return ""
}

// find row, report error if not found
pub fn (mut s Sheet) row_get(name string) !&Row {
	return s.rows[name] or{
		return error("could not find row with name: $name")
	}
}

// find row, report error if not found
pub fn (mut s Sheet) cell_get(row string, col int) !&Cell {
	mut r:=s.row_get(row)!
	mut c:=r.cells[col] or {
		return error("could not find cell from col:$col for row name: $row")
	}
	return &c
}
