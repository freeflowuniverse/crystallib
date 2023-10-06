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

!!hr.employee_define 
    cost:1:12000,12:14000
    department:engineering
    descr:'Senior Engineer'
    id:prT
    nrpeople:0:5,20:5


!!hr.employee_define 
    cost:12000EUR
    department:engineering
    descr:CTO
    id:Ruo
    indexation:10%


!!hr.employee_define 
    cost:10000USD
    department:engineering
    descr:'Senior Architect'
    id:dUm
    indexation:5%
    nrpeople:0:5,20:10


!!hr.employee_define 
    cost:4000USD
    department:engineering
    descr:'Junior Engineer'
    id:cug
    indexation:5%
    nrpeople:0:5,20:10



```


## Operations


```js

!!hr.employee_define 
    cost:1:8000,12:14000
    department:ops
    descr:'Ops Manager'
    id:Njn


!!hr.employee_define 
    cost:2000EUR
    cost_percent_revenue:1%
    department:ops
    descr:'Support Junior'
    id:JFK
    indexation:5%
    nrpeople:7:5,18:10


!!hr.employee_define 
    cost:5000EUR
    cost_percent_revenue:1%
    costcenter:tfdmcc:25,cs_tfcloud:75
    department:ops
    descr:'Support Senior'
    generate_page:../employees/support_senior.md
    id:ooe
    indexation:5%
    nrpeople:3:5,20:10


```