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
    descr:'Senior Engineer' 
    cost:'1:12000,12:14000'
    department:'engineering'
    nrpeople:'0:5,20:5'

!!hr.employee_define 
    descr:'CTO'  
    cost:'12000EUR' indexation:'10%' 
    department:'engineering'

!!hr.employee_define 
    descr:'Senior Architect'  
    cost:'10000USD' indexation:'5%' 
    department:'engineering'
    nrpeople:'0:5,20:10'

!!hr.employee_define 
    descr:'Junior Engineer' 
    cost:'4000USD' indexation:'5%' 
    department:'engineering'
    nrpeople:'0:5,20:10'


```


## Operations


```js

!!hr.employee_define 
    descr:'Ops Manager' 
    cost:'1:8000,12:14000'
    department:'ops'

!!hr.employee_define 
    descr:'Support Junior'  
    cost:'2000EUR' indexation:'5%' 
    department:'ops'
    nrpeople:'7:5,18:10'
    cost_percent_revenue:'1%'

!!hr.employee_define 
    descr:'Support Senior'  
    cost:'5000EUR' indexation:'5%' 
    department:'ops'
    nrpeople:'3:5,20:10'
    cost_percent_revenue:'1%'
    costcenter:'tfdmcc:25,cs_tfcloud:75'
    generate_page:'../employees/support_senior.md'
    

```