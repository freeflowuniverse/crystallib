module bizmodel
import freeflowuniverse.crystallib.biz.spreadsheet
// import freeflowuniverse.crystallib.core.playbook
// import freeflowuniverse.crystallib.ui.console


pub struct BizModel {
pub mut:
	name string
	sheet     spreadsheet.Sheet
	employees map[string]&Employee
}

