```js

//set means we overwrite if anything is already there
!param.set coderoot:'~/hero/code'
//setdefault means we only set if the param doesn't exist yet
!param.setdefault codereset:true
!snipet ca coderoot:${coderoot} pull:true reset:${codereset}
```