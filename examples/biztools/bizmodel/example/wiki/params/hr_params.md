# HR Params

## Engineering

possible parameters

- descr, description of the function (e.g. master architect)
- cost, any currency eg. 1000usd
  - in case cost changes over time e.g. 1:10000USD,20:20000USD,60:30000USD
- indexation, e.g. 2%
- department
- name, e.g. for a specific person
- nrpeople: how many people per month, growth over time notation e.g. 1:10,60:20  means 10 in month 1 growing to 20 month 60
- cost_percent_revenue e.g. 4%, will make sure the cost will be at least 4% of revenue

```js

!!bizmodel.employee_define  bizname:'test'
    sid:2
    descr:'Senior Engineer' 
    cost:'1:12000,12:14000' //cost is always per person
    department:'engineering'
    nrpeople:'0:5,20:5'

!!bizmodel.employee_define  bizname:'test'
    name:'despiegk'
    title: 'CTO and crazy inventor.'
    sid:3
    descr:'CTO'  
    cost:'12000EUR'  //the salary is the cost independent of the fulltime status
    indexation:'10%' 
    department:'coordination'
    page:'cto.md'
    fulltime: "50%" //100% means yes

!!bizmodel.employee_define  bizname:'test'
    descr:'Senior Architect'  
    cost:'10000USD' indexation:'5%' 
    department:'engineering'
    nrpeople:'0:5,20:10'

!!bizmodel.employee_define bizname:'test'
    descr:'Junior Engineer' 
    cost:'4000USD' indexation:'5%' 
    department:'engineering'
    nrpeople:'0:5,20:10'

```


## Operations

```js

!!bizmodel.employee_define bizname:'test'
    descr:'Ops Manager' 
    cost:'1:8000,12:14000'
    department:'ops'
!!bizmodel.employee_define bizname:'test'
    descr:'Support Junior'  
    cost:'2000EUR' indexation:'5%' 
    department:'ops'
    nrpeople:'7:5,18:10'
    cost_percent_revenue:'1%'
!!bizmodel.employee_define bizname:'test'
    descr:'Support Senior'  
    cost:'5000EUR' indexation:'5%' 
    department:'ops'
    nrpeople:'3:5,20:10'
    cost_percent_revenue:'1%'
    costcenter:'tfdmcc:25,cs_tfcloud:75'
    generate_page:'../employees/support_senior.md'
```