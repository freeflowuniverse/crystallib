module organization

import freeflowuniverse.protocolme.models.backoffice.budget
import freeflowuniverse.protocolme.people

// company structure
pub struct Company {
pub mut:
	name                 string
	circles              map[string]&people.Group
	registration_country &people.Country
	budget               &budget.Budget
}

//? In this case is it best to input full name and search data.people for that name?

pub struct CompanyNewArgs {
pub mut:
	name                 string
	circles              map[string]&Group
	registration_country &people.Country
}

pub fn (mut company Company) budget_create() &budget.Budget {
	budget := budget.Budget{}
	company.budget = &budget
	return &budget
}
