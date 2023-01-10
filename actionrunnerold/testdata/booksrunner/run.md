## Get Our Code Repositories

!!books.add
path:'https://github.com/threefoldfoundation/books/tree/main/books/technology/src'
name:technology

<!-- path can be a path or url, if gitsource specified will append to the git it points too -->

!!books.add
gitsource:'books'
path:'technology/src'
name:technology2

<!-- export to a chosen path or url -->

!!books.mdbook_export name:technology path:'/tmp/exportedbook'

<!--!!books.export name:myname url:'https://github.com/threefoldfoundation/home'-->

<!-- export all books -->
<!-- //!!books.mdbook_export name:* -->

!!books.mdbook_develop name:technology

<!-- !!publishtools.publish server:'ourserver.com' -->
