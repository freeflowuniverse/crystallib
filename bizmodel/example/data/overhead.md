# Generic Overhead Costs

possible parameters

- name
- descr: description of the cost
- cost: is 'month:amount,month:amount, ...'
- type: travel, admin, legal, varia

Other financial flows can be mentioned here as well.


```js
!!funding.define
    name:'our_investor'
    descr:'A fantastic super investor.'  
    investment:'3:1000000EUR'
    type:'loan'

!!funding.define
    name:'afounder'
    descr:'Together Were Strong'  
    investment:'1:1000000EUR'
    type:'loan'


```

