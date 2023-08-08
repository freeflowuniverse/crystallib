module bizmodel

import freeflowuniverse.crystallib.spreadsheet
import freeflowuniverse.crystallib.baobab.actions
import freeflowuniverse.crystallib.params
import freeflowuniverse.crystallib.texttools



pub struct Product {
pub mut:
	name string
	description string
	params params.Params
	bizmodel &BizModel [str: skip]
}

//return wiki info about product
pub fn (mut p Product) wiki() !string {

	mut out:="

	# Product ${p.name}

	${p.description}



	"

	return texttools.dedent(out)	

}