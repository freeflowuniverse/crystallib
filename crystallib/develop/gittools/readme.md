# GitTools


> can change coderoot with: ```export CODEROOT="/tmp/codetest"```

Are good tools to allow you to work with GIT in a programatic way

Git repo's get checked out under

- multibranch: $homedir/code/multi/accountname/reponame/branchname/code 
- single brach (default): $homedir/code/accountname/reponame/code

>TODO: need to check this multibranch could be its broken

## heroscript

- cmd      string // clone,commit,pull,push,delete
- filter   string // if used will only show the repo's which have the filter string inside
- repo     string
- account  string
- provider string
- msg      string
- url      string
- pull     bool
- reset    bool = true // means we will lose changes (only relevant for clone, pull)
- coderoot string //where do we want to checkout the code
}

```js

// clone,commit,pull,push,delete
!!gittools.clone coderoot:'/tmp/code' pull:true reset:true 
        url:'https://git.ourworld.tf/home/info_freeflowuniverse' 


```

## Objects

- Structure of all found gitrepo's
- GitRepo
  - linked to one or more git addresses
  - linked to a specific repository as its stored on the local filesystem
  - links to gitstructure
- GitAddress
  - links to gitstructure
  - can retrieve gitrepo from it but not linked
- GitLocator
  - always has GitAddress
  - a gitlocator is nothing without gitaddress

## get gitstructure and repo

```v
import freeflowuniverse.crystallib.develop.gittools

coderoot := '/tmp/code_test'
mut gs := gittools.get(coderoot: coderoot)!

mut path := gittools.code_get(
    coderoot: coderoot
    pull: true
    reset: true    
    url: 'https://github.com/despiegk/ourworld_data'
)!

gs_default.list()!
gs.list()!


```


result is something like


```v

GitRepo{
    id: 8
    path: '/Users/despiegk1/code/github/threefoldfoundation/www_examplesite'
    addr: freeflowuniverse.crystallib.gittools.GitAddr{
        provider: 'github.com'
        account: 'threefoldfoundation'
        name: 'www_examplesite'
        path: 'manual'
        branch: 'development'
        anker: ''
        depth: 0
    }
    state: ok
}

#THIS IS THE PATH WHERE THE CONTENT GOT CHECKED OUT
~/code/github/threefoldfoundation/www_examplesite/manual

- bettertoken/info_bettertoken                 development             CHANGED
- despiegk/data                                master                  CHANGED
- despiegk/htmx_vweb                           master                  CHANGED
- freeflowtribe/info_thesourcecode             development             CHANGED
- freeflowuniverse/crystallib                  development_publisher3  CHANGED
- freeflowuniverse/crystaltools                development_refactor    CHANGED
- freeflowuniverse/freeflow_network            main                    CHANGED
- freeflowuniverse/home                        development             CHANGED
- freeflowuniverse/info_freeflow_internal      development             CHANGED
- freeflowuniverse/info_freeflow_pub           development             CHANGED
- freeflowuniverse/twinactions                 development             CHANGED
- omni-sphere/info_vlang                       main                    CHANGED
- ourworld-tsc/ourworld_books                  development             CHANGED
- ourworld-tsc/ourworld_digital_bank           main                    CHANGED

```

## GIT ADDRESS

```
url := 'https://github.com/vlang/v/blob/master/doc/docs.md#maps'
obj := addr_get_from_url(url) or { panic('$err') }

//result ->
GitAddr{
    provider: 'github.com'
    account: 'vlang'
    name: 'v'
    path: 'doc/docs.md'
    branch: 'master'
    anker: 'maps'
    depth: 0
}

//another example starting from git@ ... url, works in same way
url := 'git@github.com:crystaluniverse/publishtools/tree/development/doc'
obj := addr_get_from_url(url) or { panic('$err') }

tocompare := GitAddr{
    provider: 'github.com'
    account: 'crystaluniverse'
    name: 'publishtools'
    path: 'doc'
    branch: 'development'
    anker: ''
    depth: 0
}

```

is a cool mechanism to get the unique location to a part on page from a url

## USAGE OF ENV VARIABLES

```v
if 'MULTIBRANCH' in os.environ() {
    gs.multibranch = true
}

if 'DIR_CODE' in os.environ() {
    gs.config.root = os.environ()['DIR_CODE'] + '/'
} else {
    gs.config.root = '$os.home_dir()/code/'
}
```

> MULTIBRANCH and DIR_CODE can be set

- multibranch means we will checkout under $homedir/code/multi/accountname/reponame/branchname/code 
    - in stead of  $homedir/code/accountname/reponame/code