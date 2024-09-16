# KnowledgeTree

this tool can be seen like a pre-processor for collections of markdown docs which

- fixes links
- re-sizes images
- checks on errors in the pages and report on them in errors.md file e.g. checks links in collections
- can find pages, ... in other collections
- when a image is in other collection then it get's copied in the local collection (no re-use of images from other collections)
- exports collections to a new dir all prepared to be used in another tool (e.g. mdbook)
- make it easy for other tools to find an image, page, from out of memory
- macro's get processed eg. html macro's (heroscript to nice html)
- includes are execute, include pages in other pages

the result is structure in memory or exported files in a new dir, representing the collection but processed

## Tree

A tree is our main object which holds all the collections.

## Collections

Are X nr of heroscripts, pages and images grouped, each collection has a name and location on normally a version controlled directory e.g. a github repo directory.

Content is

- heroscripts = action statements, which can also represent data objects
- md pages (the source as can be used for websites, books, ...)
- images (in multiple formats) or video's
- files

At the root of such a dir you have a .collection file

in this file there can be ```name = 'mycollectionname' ``` if you want to specify another name as the dir, if not specified the collection name will be the dirname.


## Example

```v
import freeflowuniverse.crystallib.data.doctree

mut tree:=doctree.new(name:"test")!

// path      string
// heal      bool = true // healing means we fix images
// git_url   string
// git_reset bool
// git_root  string
// git_pull  bool
// load      bool = true // means we scan automatically the added collection
for project in 'projectinca, legal, why, web4,tfgrid3,companies'.split(',').map(it.trim_space()) {
	tree.scan(
		git_url:  'https://git.ourworld.tf/tfgrid/info_tfgrid/src/branch/development/collections/${project}'
		git_pull: false
	)!
}

tree.export(dest:"/tmp/test",reset:true,keep_structure:true,exclude_errors:false,production:true)!


```

## heroscript example

A good example how to use hero

> see https://git.ourworld.tf/tfgrid/info_tfgrid/src/branch/development/heroscript/exporter/run.sh



```
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
