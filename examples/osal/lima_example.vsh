#!/usr/bin/env v -w -enable-globals run

import freeflowuniverse.crystallib.osal.lima
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.ui.console
import os

// lima.vm_delete_all()!
// lima.vm_new(reset:true,template:.alpine,name:'alpine',install_crystal:true)!
lima.vm_new(reset:true,template:.ubuntu,name:'ubuntu',install_crystal:true)!
// lima.vm_new(reset:true,template:.arch,name:'arch',install_crystal:true)!

// mut vm:=lima.vm_get('ubuntu')!
// vm.install_crystal()!

// console.print_debug_title("MYVM", vm.str())