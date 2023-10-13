# Git

## git.init

Init the git structure, defines which root to use, ...

Can only be used when initializing the context (not afterwards).

**env arguments**

has also support for os.environ variables

- MULTIBRANCH
- DIR_CODE , default: ${os.home_dir()}/code/

#### Params

- name
  - name as will be used for the git, will be referenced as gitname in further actions
- multibranch bool
  - all branches will be on separate dir
  - path of a dir will be $codedir/github/myrepo/$branchname/... 
- root        string
  - where will the code be checked out
  - all repo's are checked out on $codedir/github/myrepo (unless if multibranch)
- pull        bool
  - means we will pull every time we get a repo, otherwise will just return location
- reset       bool
  - be careful, this means we will reset when pulling
  - will overwrite changes
- light       bool  
  - if set then will clone only last history for all branches		
- log         bool 
  - means we log the git statements
- filter      string


## git.get

Will get repo starting from url, if the repo does not exist, only then will pull.

If pull is set on true, will then pull as well.

the path of the pulled content is in actions.results["gitpath_${name}"], is handy to further process.

**url examples**

- https://github.com/threefoldtech/tfgrid-sdk-ts
- https://github.com/threefoldtech/tfgrid-sdk-ts.git
- git@github.com:threefoldtech/tfgrid-sdk-ts.git

**to specify a branch and a folder in the branch for the url**

- https://github.com/threefoldtech/tfgrid-sdk-ts/tree/development/docs

#### Params

- name string [required]
  - is the name which identifies the information pulled
- gitname 
  - if a specific gistructure will be used e.g. with different root, default is 'default'
- url (string)
  - see url examples
- branch string
- pull   bool
  - will pull if this is set
  - will not overwrite unless reset is also set
- reset  bool
  - will pull and reset all changes


