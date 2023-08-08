# MDBook

Uses the library function from books to parse content into library, books and collections.

This module will export such a book to an MDBook format.

## the concepts

### library

- is a set of collections grouped in a structure
- a set of books
- 

### collections

- a collection is a bunch of pages in a folder
- each name of image and page is unique
- all names are fixed (see name_fix function), so they are all common and easy to find back
- as collections get loaded the following happens
  - all names are fixed
  - images which are too big are redone
  - images once processed get _ at end so this tool know not to process again
  - the tool will check that files and images are unique

### page

- a page is a file in markdown format
- the markdown becomes a doc object linked to the page
- this doc object allows to find/proces macro's 
- this doc object allows rendering to html or markdown (fixed or processed after macros)


### book

- is a nr of collections which have pagea inside
- a book is not sorted or ready for publishing yet, its just a set of collections in an organized 


### mdbook

- is collection of sorted pages
