## Get Our Code Repositories

!!git.pull url:'https://github.com/ourworld-tsc/ourworld_books/tree/development/content' name:'owb'
!!git.pull url:'https://github.com/threefoldfoundation/books/tree/main/books' name:'books'

!!git.params.multibranch name:'books'

//needs to include the content, not as macro
!!include path:'run_include.md'
!!git.link
gitsource:owb
gitdest:books
source:'tanzania_feasibility/technology'
dest:'feasibility_study_internet/src/capabilities2'

<!-- is same as above -->

!!git.link
source:'https://github.com/ourworld-tsc/ourworld_books/tree/development/content/tanzania_feasibility/technology'
dest:'https://github.com/threefoldfoundation/books/tree/main/books/feasibility_study_internet/src/capabilities'
