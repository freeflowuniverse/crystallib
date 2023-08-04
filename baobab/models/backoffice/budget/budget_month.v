module budget

import freeflowuniverse.protocolme.models.backoffice.finance

// budget_month
// This file deals with all definitions and functions for creating
// the budget for a certain month

[heap]
pub struct BudgetMonth {
pub mut:
	month int
	year  int
	items []BudgetItemMonth
	cost  &finance.Amount
}

pub struct BudgetItemMonth {
pub mut:
	budget_item &BudgetItem
	cost        &finance.Amount
}

// function to turn a BudgetItem into a BudgetItemMonth
pub fn (item BudgetItem) to_month(month int, year int) &BudgetItemMonth {
	// match typeof(item) {
	// 	&BudgetItemGeneric {generic_to_month(month, year)}
	// 	&BudgetItemPerson {person_to_month(month, year)}
	// 	&BudgetItemOffice {office_to_month(month, year)}
	// 	else {}
	// }

	month_item := BudgetItemMonth{}

	return &month_item
}

fn (item &BudgetItemGeneric) generic_to_month(month int, year int) &BudgetItemMonth {
	new_item := BudgetItemMonth{}
	return &new_item
}

fn person_to_month() {
	println('person_to_month')
}

fn office_to_month() {
	println('office_to_month')
}
