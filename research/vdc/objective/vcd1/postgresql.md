# deploy a postgresql cluster



```javascript

//look for 4 dedicated nodes, in line to selector... link them to vdc myvdc
!!vdc.db_define vdc:'myvdc' name:'db1' selector:'myselector' count:3 type:'postgresql'

```
