## Get Our Code Repositories

!!git.pull url:'https://github.com/ourworld-tsc/ourworld_books/tree/development/content name:'owb'
!!git.pull url:'https://github.com/threefoldfoundation/books/tree/main/books name:'books'

//needs to include the content, not as macro
!!include path:'run_include.md' 
!!git.link 
    gitsource:owb 
    gitdest:books
    source:'feasibility_study/Capabilities' 
    to:'feasibility_study_internet/src/capabilities2'

<!-- is same as above -->
!!git.link 
    source:'https://github.com/ourworld-tsc/ourworld_books/tree/development/content/feasibility_study/Capabilities' 
    to:'https://github.com/threefoldfoundation/books/tree/main/books/feasibility_study_internet/src/capabilities'

<!-- if name not specified, will use the name of the directory -->
!!books.add 
    path:'https://github.com/threefoldfoundation/books/tree/main/books/technology/src' 
    name:technology

<!-- path can be a path or url, if gitsource specified will append to the git it points too -->
!!books.add 
    gitsource:'books'
    path:'technology/src' 
    name:technology2


<!-- export to a chosen path or url -->
!!books.export name:technology path:'/tmp/exportedbook'
!!books.export name:technology url:'https://github.com/test/test/test'

<!-- export all books -->
<!-- //!!books.mdbook_export name:* -->

!!books.mdbook_develop name:myname

<!-- !!publishtools.publish server:'ourserver.com' -->