#!/usr/bin/env -S v -gc none -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

import toml
import toml.to
import json
import os
import freeflowuniverse.crystallib.data.encoderhero
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.blockchain.stellar


mut cl:= stellar.new_horizon_client()!

mut a:= cl.get_account("GB2KXHBMYRIKWNQCDK7TCOQ6ANOCD2OFTBHSS5FNIN7OS67I2UBMRHCO")!

println(a)