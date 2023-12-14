# KnowledgeTree

this tool can be seen like a pre-processor for collections of markdown docs which 

- fixes links
- re-sizes images
- checks on errors in the pages and report on them in errors.md file e.g. checks links in collections
- can find pages, ... in other collections
- when a image is in other collection then it get's copied in the local collection (no re-use of images from other collections)
- exports collections to a new dir all prepared to be used in another tool (e.g. mdbook)
- make it easy for other tools to find an image, page, from out of memory
- macro's get processed eg. html macro's (3script to nice html)
- includes are execute, include pages in other pages

the result is structure in memory or exported files in a new dir, representing the collection but processed

## Tree

A tree is our main object which holds all the collections.

## Collections

Are X nr of 3scripts, pages and images grouped, each collection has a name and location on normally a version controlled directory e.g. a github repo directory.

Content is

- 3scripts = action statements, which can also represent data objects
- md pages (the source as can be used for websites, books, ...)
- images (in multiple formats) or video's
- files

At the root of such a dir you have a .collection file

in this file there can be ```name = 'mycollectionname' ``` if you want to specify another name as the dir, if not specified the collection name will be the dirname.


## Example

```v
import freeflowuniverse.crystallib.data.knowledgetree

mut tree:=knowledgetree.tree_get(cid:"abc",name:"test")!

//the next scan operation will pull information from git and process
tree.scan(
	heal:true
	git_url:'https://git.ourworld.tf/threefold_coop/mydocs/src'
	git_root:'/tmp/code'
	git_pull:true
)!

//will scan all collections (each dir which has  .collection file inside is a collection)
tree.scan("/data/mybooks/collections")! 



```

## what are the features of the healing (fixing)

- fix all links so they point to existing path following is supported
  - ```[mylink](MyFile .md) --> [mylink](myfile.md)```
  - rename the file so its always normalized: ```'My__File .md' -> 'my_file.md'```
  - ```[mylink](MyFile) --> [mylink](myfile.md)``` //put.md at end
  - ```[mylink](anothercollection:MyFile) --> [mylink](myfile.md)``` //check the collection exists, make error if not
  - images get resized (see crystallib/docs/tools.imagemagick.html) and potentially converted to jpeg
  - then we will go over all links to see if e.g. myimage.png became myimage.jpeg and fix the link
  - an errors.md file is written so we can easily see what cannot be fixed
  - if a markdown file or image is in same collection then we replace link to ```[mylink](pathincollection/.../mylink.md)```
    - this makes it easy for editing files in editor like visual studio code, we will see e.g. the images right away
- fixing of markdown
  - we use the markdown parser to read the markdown and write the markdown again, this will rewrite actions, ...
  - the markdown will now have reproduceable format


## what are the features of the processing

- collections can be expored to specified dir
- when exporting the following will happen
  - healing (even if it was not done at source), see above
  - re-write markdown
  - process the markdown macro's which are in the markdown (next phase, ask Kristof how)

## what is the link with the mdbook osal tool

- once the collections are exported in a new structure, then we know they are clean to be processed by the mdbook tool
- that tool will read the collections again as well as summary.md and produce a book

## known issues

it might be following is needed on OSX

```bash
ulimit -n 1024
```


## TODO: lets finish this module

Hi Mario, Ashraf,

The documentation is now better should be easier to make the tool work as intented, no need to do anything with mdbook in here, that will be at the end.

> todo: crystallib/data/doctree/fix_test.v can you do this file with tests, its important one

note how we copy the originals back so we can do the test many times

check on following

- errors.md file is created and has the errors
- the links are properly repaired
- the images are properly repaired (you will have to put 1 png in original dir, then check it becomes jpeg and link changed)
- the markdown output is ok

once we have this module working properly then generating mdbook out of it, is super easy, is last step.



