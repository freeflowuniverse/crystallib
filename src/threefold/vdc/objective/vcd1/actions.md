# actions relevant for a VDC

All define but these actions are declarative and define the state we are working for, but sometimes its needed to force an action, we call those VDC actions


```javascript
!!vdc.action_delete vdc:'myvdc' //names are not needed for actions, this will delete in reality the vdc called myvdc
```    

once executing this it means the myvdc is removed and will be automatically recreated because is still defined declarative

to remove from the declarative behavior, we just need to remove the relevant 3script actions

```javascript

!!vdc.action_delete vdc:'myvdc' vm:'vm1' //will only delete one vm now
!!vdc.action_delete vdc:'myvdc' container:'vm1'

```
