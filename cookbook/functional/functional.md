

## map / filter

walk over a list and execute a function on it ("it" is used)

```golang

import os
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.installers.base

mut names := ["Guy De Spiegeleer ","Apple Tie","My Tree"," to remove because starts with"]

mut res:=names.filter(!it.starts_with(" ")).map(texttools.name_fix(it)).sorted()

println(res)

assert res==['apple_tie', 'guy_de_spiegeleer', 'my_tree']

```

## split as swiss army knife

There are some very cool tools in texttools to work with results as produced by command lines

```golang

struct ProcessItem{
    name string
    pid int
    state ProcessState
}

enum ProcessState{
    unknown
    detached
}

pub fn processit(item_ map[string]string) ProcessItem {
	mut item:=ProcessItem{}
	state_item:=item["state"].trim("() ").to_lower() or {panic("bug")}
    item.state = match state_item{
        "detached" {.detached}
        else {.unknown}
    }
    pre := item_["pre"] or {panic("bug")}
    item.pid = pre.split_after(".").trim_space().int()
    item.name = pre.split_before(".").trim_space()
	return item
}

t2:='
	11849.mysession	(Detached)
	17633.tracker	(Detached)
	7414.ttys003.KDSPRO	(Detached)
'

r5:=texttools.to_list_map("pre,state",t2,"").map(processit(it))
assert  [{'pre': '11849.mysession', 'state': 'detached'}, 
	{'pre': '17633.tracker', 'state': 'detached'}, 
	{'pre': '7414.ttys003.KDSPRO', 'state': 'detached'}] == r5

```

## manage arrays


```golang
a.clear() //empties the array without changing cap (equivalent to a.trim(0))
a.contains()
a.delete_last() //removes the last element
a.delete_many(start, size) //removes size consecutive elements from index start – triggers reallocation
a.delete(index) //equivalent to a.delete_many(index, 1)
a.first() //equivalent to a[0]
a.insert(i, [3, 4, 5]) //inserts several elements
a.insert(i, val) //inserts a new element val at index i and shifts all following elements to the right
a.join(joiner) //concatenates an array of strings into one string using joiner string as a separator
a.last() //equivalent to a[a.len - 1]
a.pop() //removes the last element and returns it
a.prepend(arr) //inserts elements of array arr at the beginning
a.prepend(val) //inserts a value at the beginning, equivalent to a.insert(0, val)
a.repeat(n) //concatenates the array elements n times
a.reverse_in_place() //reverses the order of elements in a
a.reverse() //makes a new array with the elements of a in reverse order
a.trim(new_len) // truncates the length (if new_length < a.len, otherwise does nothing)
```

see [here for more](https://modules.vlang.io/index.html#array)