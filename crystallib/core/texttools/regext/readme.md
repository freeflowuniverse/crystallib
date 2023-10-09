# regex

## basic regex utilities

- .

## regex replacer

Tool to flexibly replace elements in file(s) or text.

next example does it for 

```golang
text := '

this is test_1 SomeTest
this is Test 1 SomeTest

need to replace TF to ThreeFold
need to replace ThreeFold0 to ThreeFold
need to replace ThreeFold1 to ThreeFold

'

text_out := '

this is TTT SomeTest
this is TTT SomeTest

need to replace ThreeFold to ThreeFold
need to replace ThreeFold to ThreeFold
need to replace ThreeFold to ThreeFold

'

mut ri := regex_instructions_new()
ri.add(['TF:ThreeFold0:ThreeFold1:ThreeFold']) or { panic(err) }
ri.add_item('test_1', 'TTT') or { panic(err) }
ri.add_item('^Stest 1', 'TTT') or { panic(err) } //will be case insensitive search

mut text_out2 := ri.replace(text: text, dedent: true) or { panic(err) }

```