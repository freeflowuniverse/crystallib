# Troublesome Pages

**This chapter demonstrates that the correcct errors are raised for certain troublesome pages**

We all make mistakes, and sometimes we make these mistakes when writing markdown files for collections in our knowledgetree. It is the knowledgtree module's responsibility to not fail in case these mistakes happen, and to report them in an organized matter.

In this chapter, we demonstrate the handling of  the following mistakes:
- [Circular includes](./circular_include.md): here we include a page into a page which in turn includes the page it was included by
- [Nonexistent includes](./nonexistent_include.md): here we include a page from a collection that doesn't exist.
- [Nonexistent image](./nonexistent_image.md): here we attempt to add an image to our document that doesn't exist.
- [Nonexistent link](./nonexistent_link.md): here we attempt to add a link to a page in to our document that doesn't exist.