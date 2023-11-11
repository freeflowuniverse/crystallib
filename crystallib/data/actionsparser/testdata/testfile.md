## Get Our Code Repositories

```js

!!git.pull url:'https://github.com/ourworld-tsc/ourworld_books/tree/development/content' name:'owb'
!!git.pull url:'https://github.com/threefoldfoundation/books/tree/main/books' name:'books'  //should be comment 'lets see'
 
!!include path:'run_include.md'

!!git.link gitsource:owb
    gitdest:books
    source:'feasibility_study/Capabilities'
    dest:'feasibility_study_internet/src/capabilities2'

<!-- is same as above -->

!!git.link
    source:'https://github.com/ourworld-tsc/ourworld_books/tree/development/content/feasibility_study/Capabilities'
    dest:'https://github.com/threefoldfoundation/books/tree/main/books/feasibility_study_internet/src/capabilities' //comment

<!-- if name not specified, will use the name of the directory -->

!!books.add
    path:'https://github.com/threefoldfoundation/books/tree/main/books/technology/src'
    name:technology //lets see this remark is not there

<!-- path can be a path or url, if gitsource specified will append to the git it points too -->

!!books.add
    gitsource:'books'
    path:'technology/src' //comment
    name:technology2
    

!!books.mdbook_export name:feasibility_study_internet path:'/tmp/exportedbook'


!!books.mdbook_develop name:feasibility_study_internet //comment


<!-- !!publishtools.publish server:'ourserver.com' -->
#!!publishtools.publish server:'ourserver.com' --> 

```