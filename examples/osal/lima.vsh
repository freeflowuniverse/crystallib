#!/usr/bin/env v -enable-globals run

import freeflowuniverse.crystallib.osal.lima

mut n := lima.vm_list()!
println(n)
lima.vm_new(reset:true)!

