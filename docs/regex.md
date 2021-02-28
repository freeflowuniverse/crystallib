# regex 

more info see https://modules.vlang.io/regex.html

```vlang
import regex 

query := r'\[.*\]\( *\w*\:*\w+ *\)'

text := "
[ an s. s! ]( wi4ki:something )
[ an s. s! ](wiki:something)
[ an s. s! ](something)dd
d [ an s. s! ](something ) d
[  more text ]( something )  [ something b ](something)dd

"
query := r'(\[[a-z\.\! ]*\]\( *\w*\:*\w* *\))'

mut re := regex.new()
re.compile_opt(query) or { panic(err) }	

mut gi := 0
all := re.find_all(text)
for gi < all.len {
  println(':${text[all[gi]..all[gi + 1]]}:')
  gi += 2
}
println('')


```