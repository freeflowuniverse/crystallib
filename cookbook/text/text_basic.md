## basic text functions

```golang
import freeflowuniverse.crystallib.core.texttools

texttools.name_fix(name)
texttools.name_fix_no_underscore(name)

```



### some useful texttools functions

```golang
import freeflowuniverse.crystallib.core.texttools

//super easy to allow people to maoe from a string to a clean list
assert texttools.to_array("\n Something,'else'  ,yes\n").map(it.to_lower())==['something', 'else', 'yes']
remove_empty_lines() //removes all empty lines from a text block
dedent() //remove all spaces in front
indent(text string, prefix string) //indent with prefix


```