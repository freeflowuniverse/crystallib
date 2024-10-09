# Generic Overhead Costs

possible parameters

- name
- descr: description of the cost
- cost: is 'month:amount,month:amount, ...', no extrapolation
- cost_growth: is  'month:amount,month:amount, ..., or just a nr', will extrapolate
- type: travel, admin, legal, varia, office
- cost_percent_revenue e.g. 4%, will make sure the cost will be at least 4% of revenue
- indexation, e.g. 2%

Other financial flows can be mentioned here as well.


```js
!!bizmodel.cost_define bizname:'test'
    name:'rental'
    descr:'Office Rental in BE.'  
    cost:'5000'
    indexation:'2%'
    type:'office'

!!bizmodel.cost_define bizname:'test'
    name:'oneoff'
    descr:'Event in Z.'  
    cost_one:'3:50000'
    type:'event'

!!bizmodel.cost_define bizname:'test'
    name:'cloud'
    descr:'Datacenter and Cloud Costs'  
    cost:'2000eur'
    cost_percent_revenue:'2%'
    type:'cloud'


```

