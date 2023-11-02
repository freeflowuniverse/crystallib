## Using References

In general, using references in V can get tricky and lead to plenty of unwanted behavior. As such, below we outline some cases in which it is recommended to use references, and some cases in which it can be avoided.

### Using mutable fields instead of references

#### Not using references to parents

Lets say we have the following data structures:

```js
pub struct Tree {
    collections []Collection
}

pub struct Collection {
    pages []Page
}

pub struct Page {
    content string
}
```

We want to have a function 