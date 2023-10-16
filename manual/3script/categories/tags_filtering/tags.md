# tags

are in params format, are default field of each root object.

- Each rootobject has a tags property
- these tags can be named or not.
    - e.g. ```location:belgium``` would be named tag
    - e.g. ```urgent``` is not named (also called an argument or short arg)

```go
//example of tags
tags=```arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok' ```
```

these tags get converted to a params object in V.

```go
struct Params {
	params []Param
	args   []string
}

struct Param {
	key   string
	value string
}
```

We have a nice set of features how to get a param from a params object.

Tags as decsribed above can be converted to a Param object.

See [filter](filter.md) how to use filters to find relevant rootobjects in a circle.


