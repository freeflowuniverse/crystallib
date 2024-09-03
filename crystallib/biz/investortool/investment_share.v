module investortool
import freeflowuniverse.crystallib.core.playbook

@[heap]
pub struct InvestmentShares {
pub mut:
    id string
    company_ref string
    investor_ref string
    nr_shares int
    share_class string
    investment_value string
    interest string
    description string
    investment_date string
    type_ string
    comments string
}

fn play_investmentshares(mut investortool &InvestorTool,mut plbook playbook.PlayBook) ! {
    for mut action in plbook.find(filter: 'investortool.investment_shares_define')! {
        mut p := action.params
        mut investment_shares := InvestmentShares{
            id: p.get_default('id', '')!
            company_ref: p.get_default('company_ref', '')!
            investor_ref: p.get_default('investor_ref', '')!
            nr_shares: p.get_int_default('nr_shares', 0)!
            share_class: p.get_default('share_class', '')!
            investment_value: p.get_default('investment_value', '')!
            interest: p.get_default('interest', '')!
            description: p.get_default('description', '')!
            investment_date: p.get_default('investment_date', '')!
            type_: p.get_default('type', '')!
            comments: p.get_default('comments', '')!
        }
        println(investment_shares)
        investortool.investment_shares_add(investment_shares)!
    }
}
