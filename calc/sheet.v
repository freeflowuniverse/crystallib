module calc

pub struct Sheet{
pub mut:
	sheet_header []string
	rows_have_header 
	rows_headers []string
	rows []Row
	colsize int //size in nr of columns per row
	params SheetParams
}

pub struct SheetParams{
pub mut:
	visualize_cur bool //if we want to show e.g. $44.4 in a cell or just 44.4
}


//find maximum length of a cell (as string representation for a colnr)
//0 is the first col
//the headers if used are never counted
pub fn (mut s Sheet) len_col_max(colnr int) str {
	mut lmax:=0
	for row on s.rows{
		if row.len>colnr{
			mut c:=row.cell_get(colnr)!
			ll := c.repr().len
			if ll>lmax {lmax=ll} 
		}
	}


}
