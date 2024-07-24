## to run the manual

```bash
hero run -u https://github.com/freeflowuniverse/crystallib/blob/development/manual/readme.md -r
```

### heroscript

this is example rscript which will build the manual, above cmd can run it.    

```js

!!book.generate name:'crystal' title:'Crystallib Manual'
        url:'https://github.com/freeflowuniverse/crystallib/tree/development/manual/book'


!!doctree.add
    url:'https://github.com/freeflowuniverse/crystallib/tree/development/manual/collections'


```