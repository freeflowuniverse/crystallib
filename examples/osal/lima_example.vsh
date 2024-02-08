#!/usr/bin/env v -w -enable-globals run

import freeflowuniverse.crystallib.virt.lima
import freeflowuniverse.crystallib.installers.lima as limainstaller
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.ui.console
import os

mut virtmanager:=lima.new()!

// virtmanager.vm_delete_all()!
// virtmanager.vm_new(reset:true,template:.alpine,name:'alpine',install_crystal:true)!
// virtmanager.vm_new(reset:true,template:.ubuntu,name:'ubuntu',install_crystal:true)!
virtmanager.vm_new(reset:true,template:.arch,name:'arch',install_crystal:true)!

// mut vm:=virtmanager.vm_get('ubuntu')!
// vm.install_crystal()!

// console.print_debug_title("MYVM", vm.str())