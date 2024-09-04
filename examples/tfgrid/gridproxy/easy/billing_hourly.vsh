#!/usr/bin/env -S v -n -w -enable-globals -cg run

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.ui.console

contract_id := u64(119450)
mut gp_client := gridproxy.new(net:.dev, cache:false)!
bills := gp_client.get_contract_hourly_bill(contract_id)!

console.print_debug("${bills}")
