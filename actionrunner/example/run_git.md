## Get Our Code Repositories

!!git.init
path: ''
multibranch: 'false'

!!git.params.multibranch

!!git.pull url:'https://github.com/ourworld-tsc/ourworld_books/tree/development/content' name:'owb'

!!git.link
source:'https://github.com/ourworld-tsc/ourworld_books/tree/development/content/tanzania_feasibility/technology'
dest:'https://github.com/threefoldfoundation/books/tree/main/books/feasibility_study_internet/src/capabilities'

!!git.commit
url:'https://github.com/threefoldfoundation/books'
message: 'link technology from feasibility study to capabilities'
