module investortool
import freeflowuniverse.crystallib.core.playbook


//TODO add currency and ourtime types
@[heap]
pub struct Employee {
pub mut:
    id string
    user_ref string
    company_ref string
    status string
    start_date u64
    end_date u64
    salary string
    salary_low string
    outstanding string
    tft_grant f64
    reward_pool_points int
    salary_low_date u64
    comments string
}

fn play_employee(mut investortool &InvestorTool,mut plbook playbook.PlayBook) ! {
    for mut action in plbook.find(filter: 'investortool.employee_define')! {
        mut p := action.params
        mut employee := Employee{
            id: p.get_default('id', '')!
            user_ref: p.get_default('user_ref', '')!
            company_ref: p.get_default('company_ref', '')!
            status: p.get_default('status', '')!
            start_date: p.get_default('start_date', '')!
            end_date: p.get_default('end_date', '')!
            salary: p.get_default('salary', '')!
            salary_low: p.get_default('salary_low', '')!
            outstanding: p.get_default('outstanding', '')!
            tft_grant: p.get_f64_default('tft_grant', 0.0)!
            reward_pool_points: p.get_int_default('reward_pool_points', 0)!
            salary_low_date: p.get_default('salary_low_date', '')!
            comments: p.get_default('comments', '')!
        }
        println(employee)
        investortool.employee_add(employee)!
    }
}
