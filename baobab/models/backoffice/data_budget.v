module backoffice

//import freeflowuniverse.protocolme.organization
//import freeflowuniverse.protocolme.models.backoffice.finance
//import freeflowuniverse.crystallib.timetools
//import time
//import math

// generates monthly budgets
// ARGS:
// num_months int - number of monthly budgets which will be generated starting from this one
// TODO pub fn (mut memdb MemDB) monthly_budget (num_months int)

//? Do I need to import the organization module
/*
// function to add a budget item to data
// ARGS:
// name string 				 - e.g.   "travel_egypt_2022_02"
// remark string 			 - e.g.   "flights with emirates"
// start_time string 		 - can be relative or absolute
// cost_fixed string 		 - amount and currency code
// cost_fixed_min string 	 - "  "
// cost_fixed_max string 	 - "  "
pub fn (mut memdb MemDB) budget_item_add(name string, remark string, start_time string, cost_fixed string) &organization.BudgetItem {
	cost := finance.amount_get(cost_fixed)
	mut start := get_expiration_from_timestring(start_time) or {panic(error)} //TODO check this is correct

	// function to find latest id 
	mut latest_id := 0
	for id in data.budget_items.keys {
		if id.int() > latest_id {
			latest_id = id.int()
		}
	}

	id := (latest_id + 1).str()

	budget_item := organization.BudgetItem{
		name: name
		remark: remark
		start: start.to_time()
		cost_fixed: cost
		cost_fixed_min: cost
		cost_fixed_max: cost
		id: id
	}

	data.budget_items[id] = &budget_item

	return &budget_item
}

// Find a specific budget item in data
// ARGS:
// - target_id string of budget_item
pub fn (mut memdb MemDB) budget_item_find(target_id string) ?&organization.BudgetItem {
	if target_id in data.budget_items {
		return data.budget_items[target_id]
	}
	return error('Could not find budget item with id: $target_id')
}

// get monthly budget
// ARGS:
// - year string
// - month string
pub fn (memdb MemDB) monthly_budget(year string, month string) ?&organization.PeriodBudget {
	period_start := time.parse('$year-$month-01 00:00:00') or { panic(err) }

	month_ := (month.int() + 1).str()
	period_end := time.parse('$year-$month_-01 00:00:00') or { panic(err) }

	base_budget := data.get_budget(period_start, period_end)

	month_object := organization.Month{
		month: month.int()
		year: year.int()
	}

	mut period_budget := organization.PeriodBudget{
		period: &month_object
	}

	period_budget.BaseBudget = base_budget

	return &period_budget
}

// get quarterly budget
// ARGS:
// - year string
// - quarter string
pub fn (memdb MemDB) quarterly_budget(year string, quarter string) &organization.PeriodBudget {
	month := ((quarter.int() * 3) - 2).str()
	period_start := time.parse('$year-$month-01 00:00:00') or { panic(err) }

	month_ := (month.int() + 3).str()
	period_end := time.parse('$year-$month_-01 00:00:00') or { panic(err) }

	base_budget := data.get_budget(period_start, period_end)

	quarter_object := organization.Quarter{
		quarter: quarter.int()
		year: year.int()
	}

	mut period_budget := organization.PeriodBudget{
		period: &quarter_object
	}

	period_budget.BaseBudget = base_budget

	return &period_budget
}

// get yearly budget
// ARGS:
// - year string
pub fn (memdb MemDB) yearly_budget(year string) &organization.PeriodBudget {
	period_start := time.parse('$year-01-01 00:00:00') or { panic(err) }

	year_ := (year.int() + 1).str()
	period_end := time.parse('$year_-$01_-01 00:00:00') or { panic(err) }

	base_budget := data.get_budget(period_start, period_end)

	year_object := organization.Year{
		year: year.int()
	}

	mut period_budget := organization.PeriodBudget{
		period: &year_object
	}

	period_budget.BaseBudget = base_budget

	return &period_budget
}

// get budget between two points in time
// RETURNS:
// pub struct BaseBudget {
// 	budgetitems       []&BudgetItem
// 	total             int
// 	budget_breakdown  &BudgetBreakdown
// }
// TODO: Do max and min budgets
fn (memdb MemDB) get_budget(period_start system.OurTime, period_end system.OurTime) &organization.BaseBudget {
	mut relevant_budget_items := []&organization.BudgetItem
	for key, budget_item in data.budget_items {
		if budget_item.start.unix_time < period_start.unix_time {
			if budget_item.start.unix_time > period_end.unix_time {
				relevant_budget_items << budget_item
			}
		} else if budget_item.stop.unix_time < period_start.unix_time {
			relevant_budget_items << budget_item
		}
	}

	mut budget_breakdown := organization.BudgetBreakdown {} //? Does this need a &
	for budget_item in relevant_budget_items {
		mut unix_length := f64(2_629_743)
		if budget_item.start.unix_time() > period_start.unix_time() {
			unix_length -= (budget_item.start.unix_time() - period_start.unix_time())
		}
		if budget_item.stop.unix_time() < period_end.unix_time() {
			unix_length -= (budget_item.start.unix_time() - period_start.unix_time())
		}

		monthly_cost := (unix_length / 2_629_743) * budget_item.cost_fixed.val

		match budget_item.budget_item_type {
			.travel { budget_breakdown.travel += math.round(monthly_cost).str().int() }
			.wage { budget_breakdown.wage += math.round(monthly_cost).str().int() }
			.utility { budget_breakdown.utility += math.round(monthly_cost).str().int() }
			.office { budget_breakdown.office += math.round(monthly_cost).str().int() }
			//else {return some form of error} //? weird tho because this is exhaustive
		}
	}

	total := budget_breakdown.travel + budget_breakdown.wage + budget_breakdown.utility +
		budget_breakdown.office

	base_budget := organization.BaseBudget{
		budgetitems: relevant_budget_items
		total: total
		budget_breakdown: &budget_breakdown
	}

	return &base_budget
}

pub struct BudgetToolInput {
	time_periods []string
	entity_target string
	filter []string = [] // len 0 by default which is litmus test to see if all
}

// TODO: Create a summary statistics function
// TODO: Create sub functions for each element of the summary statistics

// TODO: create functions to filter budget ie on location, person etc
// probably worth discussing with Kristof or Timur the best way to do this
// Stats Overview
// - Multiple Period / Multiple Entity / Multiple BudgetType
// Periods:
// - Month
// - Quarter
// - Year
// BudgetType:
// - Travel
// - Wage
// - Utility
// - Office


// ARGS:
// time_periods []string - an array of strings of the form '2022M1' or '2022Q1' or '2022'
// filter []string - an array of the first set of entities to filter by
// entity_target string - 'people', 'companies', 'circles'
// budget_types []string - an array of string of budget_types
// ie if you want to see the budget of people in two specific circles:
// you would add the two circles to filter
// you would make the entity_target 'people'
// TODO: if a budget item has many people, are they all assigned that full cost in stats?
// TODO: add an 'all' entry option into the filters
// all will be an empty input
// TODO: add new niche ways to filter ie by person type
// For now it might be better to do proportional

// RETURN:
// a map where the key is the time period and the value is
	// a map where the key is the circle and the value is
		// a map where the key is the person and the value is
			// a BudgetStatistics struct

// map[string]map[string]map[string]organization.BudgetStatistics

/*
'time_period1':{
	'circle1':{
		'person1': {
			'budget_breakdown':{
				'total_budget':
				'wage_budget': 
				'office_type':
				'utility_budget':
			},
			'budget_items':{
				&budget_item1,
				&budget_item2,
				&budget_item3
			}
		}
		'person2': 
	},
	'circle2':{
		'person3': {}
		}
	}
*/

// input should be a struct
fn (memdb MemDB) budget_tool (input BudgetToolInput) map[string]map[string]map[string]organization.BudgetStatistics {
	for time_period in input.time_periods {
		period_start, period_end := parse_time(time_period)
		mut budget_item_slices := data.slices_get(period_start, period_end)
		budget_item_slices.filter(input.filter)
		// TODO function to filter out budget_items that don't belong to entities in the second_filter
	}
}

// Parses a time period into start and end times
// used in fn budget_tool
fn parse_time (time_period string) (system.OurTime, system.OurTime) {

	if 'M' in time_period.split(''){
		month := time_period[time_period.len-1..time_period.len]
		year := time_period[0..4]

		period_start := time.parse('$year-$month-01 00:00:00') or { panic(err) }

		month_ := (month.int() + 1).str()
		period_end := time.parse('$year-$month_-01 00:00:00') or { panic(err) }
	} else if 'Q' in time_period.split('') {
		quarter := time_period[time_period.len-1..time_period.len]
		year := time_period[0..4]

		month := ((quarter.int() * 3) - 2).str()
		period_start := time.parse('$year-$month-01 00:00:00') or { panic(err) }

		month_ := (month.int() + 3).str()
		period_end := time.parse('$year-$month_-01 00:00:00') or { panic(err) }
	} else {
		year := time_period
		period_start := time.parse('$year-01-01 00:00:00') or { panic(err) }
		
		year_ := (year.int() + 1).str()
		period_end := time.parse('$year_-$01_-01 00:00:00') or { panic(err) }
	}

	return period_start, period_end
}

// Filters budget_items by a period, creating an array of budget slices
// used in fn budget_tool
fn (memdb MemDB) slices_get (period_start system.OurTime, period_end system.OurTime) []&BudgetItemSlice {
	
	// iterates through all budget_items and only picks those which overlap with time_period
	mut budget_item_slices := []&organization.BudgetItemSlice
	for key, budget_item in data.budget_items {
		if budget_item.start.unix_time < period_start.unix_time {
			if budget_item.start.unix_time > period_end.unix_time {
				new_cost := budget_item.slice_cost.(period_start, period_end)
				budget_item_slices << budget_item.slice(new_cost)
			}
		} else if budget_item.stop.unix_time < period_start.unix_time {
			budget_item_slices << budget_item.slice(new_cost)
		}
	}

	// takes a budget_item, removing the time stamps and returning an updated cost
	fn (budget_item &BudgetItem) slice (new_cost) budget_item_slice BudgetItemSlice { 
		budget_item_slice := BudgetItemSlice {
				budget_item_type: budget_item.budget_item_type
				name: budget_item.name
				remark: budget_item.remark
				people: budget_item.people
				circles: budget_item.circles
				cost_fixed: new_cost
				type_extras: budget_item.type_extras
				id: budget_item.id
		}
		return budget_item_slice
	}

	// this function needs to calculate the proportion of the period which it was active
	fn (budget_item &BudgetItem) slice_cost (period_start system.OurTime, period_end system.OurTime) cost int {
		// OVERALL AIM: number of active days in period * monthly_cost/30
		// convert period_start and end to unix time integers
		// do logic for before and after to get total unix time
		// convert unix time into a number of days
		fn unint (time_object system.OurTime) int {
			unix_i64 := time.unix_time(time_object)
			return  unix_i64.str().int()
		}

		bi_start := unint(budget_item.start)
		bi_end := unint(budget_item.stop)
		period_start_ = unint(period_start)
		period_end_ = unint(period_end)
		
		mut unix_length := 0

		// logic to calculate the unix_length of the overlap of the target period and the budget time period
		if bi_start < period_start_ {
			if bi_end < period_end_ {
				unix_length = bi_end-period_start_
				}
			}
			else {
				unix_length = period_end_-period_start_
				}
		else {
			if bi_end < period_end_ {
				unix_length = bi_end-bi_start
				}
			}
			else {
				unix_length = period_end_-bi_start
				}

		period_cost := (unix_length / 2_629_743) * budget_item.cost_fixed.val

		return period_cost

	return budget_item_slices
}

// Filters budget item slices by company/circle/person
// used in fn budget_tool
fn (budget_item_slices []&BudgetItemSlice) filter (filter_list []&Entity)  []&BudgetItemSlice {
	// TODO identify what type of entity we are filtering by
	filtered_slices := match typeof(filter_list[0]) {
		&people.Person            {budget_item_slices.filter_by_people(filter_list)}
		&organization.Company     {budget_item_slices.filter_by_companies(filter_list)}
		&organization.Group      {budget_item_slices.filter_by_circles(filter_list)}
	}

	return filtered_slices
}

// Filters an array of budget_item_slices by people
// used in fn filter
fn (budget_item_slices []&BudgetItemSlice) filter_by_person (filter_list []&people.Person)  []&BudgetItemSlice {
	mut filtered_slices := []&BudgetItemSlice
	for item_slice in budget_item_slices {
		for person in filter_list {
			if person in item_slice.people {
				filtered_slices << item_slice
			}
		}
	}
	return filtered_slices
}

// Filters an array of budget_item_slices by circles
// used in fn filter
fn (budget_item_slices []&BudgetItemSlice) filter_by_circles (filter_list []&people.Person)  []&BudgetItemSlice {
	mut filtered_slices := []&BudgetItemSlice
	for item_slice in budget_item_slices {
		for circle in filter_list {
			if circle in item_slice.circles {
				filtered_slices << item_slice
			}
		}
	}
	return filtered_slicess
}

// Filters an array of budget_item_slices by companies
// used in fn filter
fn (budget_item_slices []&BudgetItemSlice) filter_by_companies (filter_list []&people.Person)  []&BudgetItemSlice {
	mut filtered_slices := []&BudgetItemSlice
	//? Is this process too slow?
	for company in filter_list {
		for item_slice in budget_item_slices {
			for circle in item_slice {
				if circle in company {
					filtered_slices << item_slice
				}
			}
		}
	}
	return filtered_slicess
}

*/
