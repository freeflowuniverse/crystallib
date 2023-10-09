module budget

//! OLD STUFF

// pub struct BudgetBreakdown {
// pub mut:
// 	travel  int = 0
// 	salary    int = 0
// 	office  int = 0
// 	utility int = 0
// }

// pub struct BudgetStatistics {
// 	budget_breakdown  BudgetBreakdown
// 	budget_items      []&BudgetItem
// }

// pub struct BaseBudget {
// pub mut:
// 	budgetitems      []&BudgetItem
// 	total            int
// 	budget_breakdown &BudgetBreakdown
// }

// pub struct PeriodBudget {
// 	BaseBudget
// pub mut:
// 	period &Period
// }

// pub struct Month {
// pub mut:
// 	month int
// 	year  int
// }

// pub struct Quarter {
// pub mut:
// 	quarter int
// 	year    int
// }

// pub struct Year {
// pub mut:
// 	year int
// }

// pub type Period = Month | Quarter | Year

// // budget item slice is effectively a budget item, but only for that time period
// pub struct BudgetItemSlice {
// 	budget_item_type BudgetItemType
// 	name             string
// 	remark           string
// 	people           []&people.Person
// 	circles          []&organization.Group
// 	cost_fixed       &finance.Amount
// 	type_extras      &BudgetItemExtras
// 	id               string
// }

// // struct BudgetItemOffice {}

// // struct BudgetItemUtility {}

// // struct BudgetItemPerson {}

// struct BudgetItemTravel {
// pub mut:
// 	// in 0.100 if any, is percent of hrcost
// 	location1 string
// 	location2 string
// }

// type BudgetItemExtras = BudgetItemTravel // | BudgetItemsalary | BudgetItemGeneric
