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

pub fn get()! &InvestorTool {
    if "default" in investortools{
        return investortools["default"]
    }
    return error("can't find default investor tool")
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
    it.users[user.oid] = user
}

pub fn (mut it InvestorTool) company_add(company &Company) ! {
    it.companies[company.oid] = company
}

pub fn (mut it InvestorTool) employee_add(employee &Employee) ! {
    it.employees[employee.oid] = employee
}

pub fn (mut it InvestorTool) investment_shares_add(investment &InvestmentShares) ! {
    it.investments[investment.oid] = investment
}

pub fn (mut it InvestorTool) investor_add(investor &Investor) ! {
    it.investors[investor.oid] = investor
}

pub fn play(mut plbook playbook.PlayBook) !&InvestorTool {
    mut it:= new()
    play_company(mut it, mut plbook )!
    play_employee(mut it, mut plbook )!
    play_investmentshares(mut it, mut plbook )!
    play_investor(mut it, mut plbook )!
    play_user(mut it, mut plbook )!

    investortools["default"] = it
    return it

}



pub fn (mut it InvestorTool) check() ! {
    //TODO: walk over all objects check all relationships
    //TODO: make helpers on e.g. employee, ... to get the related ones

    for _, cmp in it.companies{
        for admin in cmp.admins{
            if !(admin in it.users){
                return error('admin ${admin} from company ${cmp.oid} is not found')
            }
        }
    }

    for _, emp in it.employees{
        if !(emp.user_ref in it.users) {
            return error('user ${emp.user_ref} from employee ${emp.oid} is not found')
        }

        if !(emp.company_ref in it.companies) {
            return error('company ${emp.company_ref} from employee ${emp.oid} is not found')
        }
    }

    for _, inv in it.investments{
        if inv.company_ref != '' && !(inv.company_ref in it.companies) {
            return error('company ${inv.company_ref} from investment ${inv.oid} is not found')
        }

        if !(inv.investor_ref in it.investors) {
            return error('investor ${inv.investor_ref} from investment ${inv.oid} is not found')
        }
    }

    for _, inv in it.investors{
        for user in inv.user_refs{
            if !(user in it.users) {
                return error('user ${user} from investor ${inv.oid} is not found')
            }
        }

        for admin in inv.admins{
            if !(admin in it.users) {
                return error('admin ${admin} from investor ${inv.oid} is not found')
            }
        }
    }

    for _, user in it.users{
        for inv in user.investor_ids{
            if !(inv in it.investors) {
                return error('investor ${inv} from user ${user.oid} is not found')
            }
        }
    }
}
