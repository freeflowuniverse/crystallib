# KnowledgeTree

## Tree

Tree is the main object, holds the following objects

- collections
- books (e.g. mdbooks)
- pointers, are pointers to a book, page, image, ... anything inside a knowledge tree as a unique smartid (sid)



## Collections

Are X nr of 3scripts, pages and images grouped, each collection has a name and location on normally a version controlled directory e.g. a github repo directory.

Content is

- 3scripts = action statements, which can also represent data objects
- md pages (the source as can be used for websites, books, ...)
- images (in multiple formats) or video's
- files


## Pointer

A pointer is a pointer to a page, file or image.

It cannot be used to link to a director, because directories have no meaning in our book concept.


## known issues

it might be following is needed on OSX

```bash
ulimit -n 1024
```