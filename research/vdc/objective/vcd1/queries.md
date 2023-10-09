# queries relevant for a VDC

Queries do not change anything in mem (declarative) or in reality (actions), can be used to get information

```javascript
!!vdc.query_vm vdc:'myvdc'  //will list all vm from this VDC
!!vdc.query_all vdc:'myvdc'  //will list all objects related to this VDC
!!vdc.query_net vdc:'myvdc'
!!vdc.query_webgw vdc:'myvdc'
!!vdc.query_dns vdc:'myvdc'

//if vdc not defined then is all vdc

//can also use filters e.g.

!!vdc.query_all vdc:'myvdc' name:'*kds*' format:'json'


```    

the result default is given back as markdown, but we can also specify json 


results will include (in line to what is relevant for the object)

- name
- size params
- mount params
- status params
- ip addr params
- ...