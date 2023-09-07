	
# KnowledgeTree

## knowledgetree.scan

Scan a knowledgetree starting from path or from git

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


## knowledgetree.mdbook

Generate an mdbook from the knowledgetree based on a summary.md file which needs to be in path or the giturl.

#### Params    

- name      string [required]
- path      string
- git_url   string
- git_reset bool
- git_root  string
- git_pull  bool
- dest      string
  - default in /tmp/mdbook/$name
- mddest      string 
  - where to export the mdfiles before mdbook is generated
  - - default in /tmp/mdbook_export/$name






