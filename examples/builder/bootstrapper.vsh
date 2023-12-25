#!/usr/bin/env v -enable-globals run

import freeflowuniverse.crystallib.builder

mut b := builder.bootstrapper()

b.run(addr:'root@65.21.132.119',debug:true)!
