#!/usr/bin/env -S v -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

import freeflowuniverse.crystallib.clients.github as gh

mut cli := gh.new()!
node_id := cli.get_project_node_id('freeflowuniverse', 7)!
print(node_id)

node_ids := cli.list_project_node_ids('freeflowuniverse', 10)!
print(node_ids)

items := cli.list_project_items('PVT_kwDOA95ldc4ANQ54', 5)!
print(items)
