
## manual

the following ones wont execute because we don't have !! in front


```js
gittools.git_do 
    coderoot //location where code will be checked out 
    filter // if used will only show the repo's which have the filter string inside 
    repo            
    account         
    provider        
    print          bool = true 
    pull           bool // means when getting new repo will pull even when repo is already there 
    pullreset      bool // means we will force a pull and reset old content	 .
    commit         bool 
    commitpull     bool 
    commitpush     bool 
    commitpullpush bool 
    msg            string 
    delete         bool // remove the repo 
    script         bool = true // run non interactive (default for actions) 
    cachereset     bool //remove redis cache 
gittools.git_get 
    coderoot //location where code will be checked out 
    pull           bool // means when getting new repo will pull even when repo is already there 
    pullreset      bool // means we will force a pull and reset old content	
```

## this one will execute

```js
!!gittools.git_get coderoot:'/tmp/code4' pullreset:1 url:'https://github.com/threefoldfoundation/home'
!!gittools.git_do coderoot:'/tmp/code4' filter:'home' pull:1
```