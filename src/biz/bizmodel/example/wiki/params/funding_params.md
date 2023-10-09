# Funding Params

possible parameters

- name, e.g. for a specific person
- descr: description of the funding
- investment is month:amount,month:amount, ...
- type: loan or capital

Other financial flows can be mentioned here as well.


```js
!!funding.define
    name:'our_investor'
    descr:'A fantastic super investor.'  
    investment:'3:1000000EUR'
    type:'capital'

!!funding.define
    name:'a_founder'
    descr:'Together Are Strong'  
    investment:'2000000'
    type:'loan'



```

