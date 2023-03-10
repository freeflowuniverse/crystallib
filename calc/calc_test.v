module calc

import freeflowuniverse.crystallib.currency

fn test_sheets() {
	mut sh := sheet_new(name: 'test') or { panic(err) }

	mut nrnodes := sh.row_new(name: 'nrnodes', growth: '5:100,55:1000')!
	mut nrnodes2 := sh.row_new(name: 'nrnodes2', growth: '5:100,55:1000,60:500')!
	mut times2 := sh.row_new(name: 'times2', growth: '1:2')! // means all cells are nr 2

	mut nrnodessum := nrnodes.add('nrnodessum', nrnodes2)!
	mut nrnodesmin := nrnodes.subtract('nrnodesmin', nrnodes2)!
	mut nrnodesmulti := nrnodes.multiply('nrnodesmulti', times2)!
	mut nrnodesdiv := nrnodes.divide('nrnodesdiv', times2)!

	mut nrnodesaggr := nrnodes.aggregate('nrnodesaggr')!


	mut nrnodesdiff := nrnodes.difference('nrnodesdiff')!
	
	mut shyear:=sh.toyear(name:"nrnodesyear")!
	mut shq:=sh.toquarter(name:"nrnodesq")!

	// TODO: we need to create tests for it

	println(sh)
	println(shyear)
	println(shq)
	panic("test1")
}

// fn test_curr() {
// 	mut sh := sheet_new(name: 'test2') or { panic(err) }

// 	mut c2 := currency.Currency{
// 		name: 'AED'
// 		usdval: 0.25
// 	}
// 	sh.currencies.currencies['AED'] = &c2
// 	mut c3 := currency.Currency{
// 		name: 'EUR'
// 		usdval: 0.9
// 	}
// 	sh.currencies.currencies['EUR'] = &c3

// 	mut pricetft := sh.row_new(name: 'pricetft', growth: '1:100aed,55:1000eur')!

// 	// println( sh.rows["pricetft"].cells[0])
// 	assert sh.rows['pricetft'].cells[0].val == 25.0
// 	assert sh.rows['pricetft'].cells[60 - 1].val == 900.0

// 	// TODO: we need to create tests for it

// 	println(sh)
// 	panic('test1')
// }
