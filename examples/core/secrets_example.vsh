#!/usr/bin/env -S v -n -w -enable-globals run


import freeflowuniverse.crystallib.crypt.secrets

secrets.delete_passwd()!
r:= secrets.encrypt("aaa")!
println(r)
assert "aaa"==secrets.decrypt(r)!

