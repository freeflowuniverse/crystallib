# HR Params

## Engineering

possible parameters

- descr, description of the function (e.g. master architect)
- cost, any currency eg. 1000usd
- indexation, e.g. 2%
- department
- name, e.g. for a specific person
- nrpeople: how many people per month, growth over time notation e.g. 1:10,60:20  means 10 in month 1 growing to 20 month 60
- cost_growth: in case cost changes over time (then don't use indexation and cost) e.g. 1:10000USD,20:20000USD,60:30000USD


```js

!!hr.employee_define 
    descr:'Senior Engineer' 
    cost:'1:12000USD,12:14000'
    department:'engineering'
    nrpeople:'1:5,20:5'

!!hr.employee_define 
    descr:'CTO'  
    cost:'12000USD' indexation:'10%' 
    department:'engineering'

!!hr.employee_define 
    descr:'Senior Architect'  
    cost:'10000USD' indexation:'5%' 
    department:'engineering'
    nrpeople:'1:5,20:10'

!!hr.employee_define 
    descr:'Junior Engineer' 
    cost:'4000USD' indexation:'5%' 
    department:'engineering'
    nrpeople:'1:5,20:10'


```

