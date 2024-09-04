module investortool

import freeflowuniverse.crystallib.core.playbook

//TODO: need to do a global
__global(
    investortools shared map[string]&InvestorTool
)

@[heap]
pub struct InvestorTool {
pub mut:
    companies map[string]&Company
	employees map[string]&Employee
	investments map[string]&InvestmentShares
	investors map[string]&Investor
	users map[string]&User

}


// Factory methods
pub fn new() &InvestorTool {
    return &InvestorTool{}
}


// Factory methods
pub fn (mut it InvestorTool) user_new() &User {
    return &User{}
}

pub fn (mut it InvestorTool) company_new() &Company {
    return &Company{}
}

pub fn (mut it InvestorTool) employee_new() &Employee {
    return &Employee{}
}

pub fn (mut it InvestorTool) investment_shares_new() &InvestmentShares {
    return &InvestmentShares{}
}

pub fn (mut it InvestorTool) investor_new() &Investor {
    return &Investor{}
}

// Add methods
pub fn (mut it InvestorTool) user_add(user &User) ! {
    it.users[user.id] = user
}

pub fn (mut it InvestorTool) company_add(company &Company) ! {
    it.companies[company.id] = company
}

pub fn (mut it InvestorTool) employee_add(employee &Employee) ! {
    it.employees[employee.id] = employee
}

pub fn (mut it InvestorTool) investment_shares_add(investment &InvestmentShares) ! {
    it.investments[investment.id] = investment
}

pub fn (mut it InvestorTool) investor_add(investor &Investor) ! {
    it.investors[investor.id] = investor
}

fn play(mut plbook playbook.PlayBook) ! {
    mut it:= new()
    play_company(mut it, mut plbook )!
    play_employee(mut it, mut plbook )!
    play_investmentshares(mut it, mut plbook )!
    play_investor(mut it, mut plbook )!
    play_user(mut it, mut plbook )!

}

//TODO: do one play command call all the play commands for each object

