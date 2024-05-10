module accountant

import baobab.seeds.finance { Budget }
import freeflowuniverse.crystallib.baobab.backend

// news the Budget with the given object id
pub fn (mut actor Accountant) new_budget(budget Budget) !string {
	return actor.backend.new[Budget](budget)!
}

// gets the budget with the given object id
pub fn (mut actor Accountant) get_budget(id string) !Budget {
	return actor.backend.get[Budget](id)!
}

// gets the Budget with the given object id
pub fn (mut actor Accountant) set_budget(budget Budget) ! {
	actor.backend.set[Budget](budget)!
}

// deletes the Budget with the given object id
pub fn (mut actor Accountant) delete_budget(id string) ! {
	actor.backend.delete[Budget](id)!
}

// lists all of the budget objects
pub fn (mut actor Accountant) list_budget() ![]Budget {
	return actor.backend.list[Budget]()!
}
