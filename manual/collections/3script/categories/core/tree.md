
## knowledgetree

heroscript actions which work with knowledgetree

- note the first argument tree is not needed and can be skipped


## !!tree.def_set

- define a definition pr concept
- params
  - name: list of names, aliases, will be namefixed
  - description: 
  - tags: define tags relevant for this definition

## !!tree.def_print

- print a definition in markdown format
- params
  - header_level:3 (is 1-5, is for nr of #)


## !!!!tree.include

- name is collectionname:pagename or pagename if in same collection

## !!!!tree.def_list

Is a macro, which means outputs wiki text.

- print a list of the definitions
- params
  - includefilter, use filter statements on tags
  - excludefilter, use filter statements on tags
  - show_description: bool (default true)
  - show_tags:bool (default true)


## !!tree.scan

Scan a knowledgetree starting from path or from git

> TODO: check

#### Params    

- name      string [required]
- path      string
- load      bool = true
- git_url   string
- git_reset bool
- git_root  string
- git_pull  bool
- heal      bool 
  - healing means we fix images, if selected will automatically load, remove stale links


## !!tree.mdbook

> TODO: check

Generate an mdbook from the knowledgetree based on a summary.md file which needs to be in path or the giturl.

#### Params    

- name      string [required]
- treename  string = default
- path      string
- git_url   string
- git_reset bool
- git_root  string
- git_pull  bool
- dest      string
  - default in /tmp/mdbook/$name
- mddest      string 
  - where to export the mdfiles before mdbook is generated
  - default in /tmp/mdbook_export/$name

