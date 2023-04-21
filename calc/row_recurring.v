module calc



[params]
pub struct RowRecurringArgs{
pub mut:
	name string
	tags 	string
	descr   string
	subgroup string
	aggregatetype RowAggregateType = .sum
	nrmonths int=60
	delaymonths int //how many months should we delay the output

}


pub fn (mut r Row) recurring(args RowRecurringArgs) !&Row {
	mut row_result := r
	if args.name.len>0{
		mut r3:=r.sheet.row_new(name: args.name, aggregatetype: r.aggregatetype,descr:args.descr,
				subgroup:args.subgroup,tags:args.tags)!
		row_result = *r3
	}
	mut arr:=[]f64{} //is one per starting moint
	mut prevval:=0.0
	for x in 0 .. r.sheet.nrcol {
		endnr:=min(r.sheet.nrcol,x+args.nrmonts)
		for x2 in x..endnr{
			arr[x]+=r.cells[x].val 			
		}
	}
	row_result.cells[x].empty = false
	row_result.cells[x].val = arr[x]
	}
	if args.delaymonths>0{
		row_result.delay(args.delaymonths)!
	}
	return &row_result
}

