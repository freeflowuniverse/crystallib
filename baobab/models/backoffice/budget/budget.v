module budget

import freeflowuniverse.protocolme.people

// budget
// This file deals with the main budget item

[heap]
pub struct Budget {
pub mut:
	allocation []BudgetAllocation
	planning []BudgetItem
	months []BudgetMonth
}

type BudgetAllocation = BudgetAllocationPerson //| BudgetAllocationCompany 
type BudgetItem = BudgetItemPerson | BudgetItemGeneric | BudgetItemOffice


// pub struct BudgetAllocationCompany{
// pub mut:
// 	start system.OurTime
// 	nrmonths int = 60
// 	company &organization.Company
// 	percentage int //0-100
// }

pub struct BudgetAllocationPerson{
pub mut:
	person &people.Person 
	percentage int //0-100
}




