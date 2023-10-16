module tfgrid

import threefoldtech.web3gw.tfgrid as tfgrid_client { TFGridClient }
import freeflowuniverse.crystallib.data.actionsparser { Action }
import freeflowuniverse.crystallib.rpcwebsocket { RpcWsClient }
import log { Logger }

[heap]
pub struct TFGridHandler {
pub mut:
	tfgrid   TFGridClient
	ssh_keys map[string]string
	logger   Logger
	handlers map[string]fn (action Action) !
}

pub fn new(mut rpc_client RpcWsClient, logger Logger, mut grid_client TFGridClient) TFGridHandler {
	mut t := TFGridHandler{
		tfgrid: grid_client
		logger: logger
	}

	t.handlers = {
		'core':         t.core
		'gateway_fqdn': t.gateway_fqdn
		'gateway_name': t.gateway_name
		'kubernetes':   t.k8s
		'machine':      t.vm
		'zdbs':         t.zdb
		'discourse':    t.discourse
		'funkwhale':    t.funkwhale
		'peertube':     t.peertube
		'taiga':        t.taiga
		'presearch':    t.presearch
		'nodes':        t.nodes
		'farms':        t.farms
		'twins':        t.twins
		'contracts':    t.contracts
		'stats':        t.stats
	}

	return t
}

pub fn (mut t TFGridHandler) handle_action(action Action) ! {
	handler := t.handlers[action.actor] or { return t.helper(action) }

	return handler(action)
}
