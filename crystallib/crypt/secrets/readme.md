# startup manager

some utils to manage secret keys and easily change them in text, ideal for config files.

```go
#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.crypt.secrets

mut box:=secrets.get()!
box.delete("myapp.something")! //make sure we remove all previous keys

//will generate a key (hex of 24 chars) if it doesn't exist yet .
mysecret:=box.secret(key:"myapp.something.a",reset:false)!
println(mysecret)

mut test_string := "This is a test string with {ss} and {MYAPP.SOMETHING.A} and {ABC123}."

test_string1:=box.replace(txt:test_string)!

println(test_string1)


test_string2:=box.replace(txt:test_string,defaults:{"MYAPP.SOMETHING.A":secrets.DefaultSecretArgs{secret:"AAA"}})!

println(test_string2)

```
