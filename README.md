# set of libraries

- [PLANNING HERE](https://circles.threefold.me/project/despiegk-product_publisher/issues)

As used for Threefold and ...

## to install

```bash
sh install.sh
```

## to develop

- go to ~/.vmodules/ checkout this repo under despiegk/crystallib
- edit the code there
- use `v run test.v` to run some ad hoc tests
- use `v test vredis2/` to run tests of one module

## generating docs

```bash
#cd in this directory
v doc -all -m . -o docs/ -f html
```

# main methods

## to get started

- execute install.sh
- uses library crystaluniverse/crystallib

## publisher

### load process

- find_sites: find the sites & load in mem (do not check them yet, thats next step)
- check: walk over all sites & make sure they are loaded & checked & processed (now they are in mem)
  - does: load of all sites
  - does: process of all sites
  - does: defs_pages_init is on publisher level only

### helpers

- site_locations_get: return the locations of sites
- site/page/file_get_by_id
- file/page/file_exists
- file/page/file_get
- files/pages_get
- page_file_exists_state with bool selects page or file
  - page/file_exists_state (returns a state where we can see its double, error, ok means we found it onece)

## site

- file_remember_full_path : used while finding files
- file_remember : used while finding files
- page_remember : used while finding files
- load: load the paths of files in mem and find definitions
  - files_process: find the files on the filesystem
- process: first need to load ALL sites, then can process the site (see flow below)
- reload : reload the files
- error_ignore_check: check if to ignore processing of page
- page/file_get and page/file_exists

## page

- write
- error_add: add error to page, args:(PageError,publisher)
- load : load the page & find defs
- process : process the markdown content and include other files, find links, find errors...
  - calls processlines
- title : find title of a page
- content_defs_replaced: replace the defs in the page
- site_get
- path_get : get full path of the page (don't use on struct)
- name_get : get full name in relation to site (site_prefix added if needed)

## file

- consumer_page_register: make sure the file knows that it has been used by a page
- relocate: after loading process the file, e.g. copy on right location, check how many times used, ...
- site_get
- path_get : get full path of the page (don't use on struct)
- name_get : get full name in relation to site (site_prefix added if needed)

## link

- link_parser: parses a line to find all links on that line, is the main init function
  - link_new : the factory method, create a link & init the default values, start from the descr & link text (parser uses this)
- original_get (return string, is the link as to find in the source file)
- server_get : how to represent on the server (flattened or in mem)
- source_get : how to represet in the source file
- check: used by the line processor on page (page walks over content line by line to parts links, checks if valid here)
- replace : replace text with the right link info

## def

on publisher obj:

- defs_pages_init : creates the definitions page and loads in mem
- def_page_get/exists

## tools

- name_fix: normalze
- name_fix_no_underscore: normalize name remove all \*
- name_fix_keepext: normalize name keep the extension
- name_split : split name to site,file_or_page_name

## replacer

all on publisher and as option

- name_fix_alias_page/site/file/word : go over aliases when fixing the name (does not do split)
- name_split_alias : does name split & the fix_alias...
