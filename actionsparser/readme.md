# actions

are text based representatsions of actions which need to be executed

example

```
!!tflibrary.booksmanager.book_add 
    gitsource:'books'
    path:'technology/src'
    name:technology
```

the first one is the action, the rest are the params


## to select domain, actor or book

```go
!!select_domain protocol_me
!!select_book aaa
!!select_actor people
```

Depending specified domain or book or actor, we make a default selection

