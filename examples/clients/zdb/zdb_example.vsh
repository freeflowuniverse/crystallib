#!/usr/bin/env -S v -w -cg -enable-globals run

import freeflowuniverse.crystallib.clients.zdb

mut myzdb := zdb.get('~/.zdb/socket', '1234', 'test')!
i := myzdb.nsinfo('default')!
println(i)
