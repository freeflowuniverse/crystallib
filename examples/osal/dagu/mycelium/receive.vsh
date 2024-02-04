#!/usr/bin/env v -enable-globals

import encoding.base64
import freeflowuniverse.crystallib.clients.mycelium
import freeflowuniverse.crystallib.osal.dagu
import json
import os

println('receiving message')
if msg := mycelium.receive_msg_opt(false) {
	println('received a new message: ${base64.decode_str(msg.payload)}')
	if msg.src_pk == os.getenv('HOME_PK') {
		content := base64.decode_str(msg.payload)
		dag := json.decode(dagu.DAG, content)!
		mut d := dagu.new()!
		d.new_dag(dag)
		d.start(dag.name)!
	}
}
