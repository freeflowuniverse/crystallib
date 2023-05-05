module calc

import math

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
	// mut arr:=[]f64{} //is one per starting moint
	mut prevval:=0.0
	for x in 0 .. r.sheet.nrcol {
		// arr<<0.0
		mut aggregated:=0.0
		startnr:=math.max(0,x-args.nrmonths)
		for x2 in startnr..x+1{
			aggregated+=r.cells[x2].val 			//go back max 60 months and aggregate it all
		}

		row_result.cells[x].empty = false
		row_result.cells[x].val = aggregated
	}
	if args.delaymonths>0{
		row_result.delay(args.delaymonths)!
	}
	return &row_result
}

