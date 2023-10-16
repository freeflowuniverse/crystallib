module web3gw

import log { Logger }
import freeflowuniverse.crystallib.core.actionsparser { Action }
import freeflowuniverse.crystallib.rpcwebsocket { RpcWsClient }
import threefoldtech.web3gw.threelang.clients { Clients }

[heap]
pub struct Web3GWHandler {
pub mut:
	logger   Logger
	clients  Clients
	handlers map[string]fn (Action) !
}

pub fn new(mut rpc RpcWsClient, logger &Logger, mut wg_clients Clients) Web3GWHandler {
	mut h := Web3GWHandler{
		logger: logger
		clients: wg_clients
	}
	h.handlers = {
		'keys.define':   h.keys_define
		'money.send':    h.money_send
		'money.swap':    h.money_swap
		'money.balance': h.money_balance
	}
	return h
}

pub fn (mut h Web3GWHandler) handle_action(action Action) ! {
	key := '${action.actor}.${action.name}'
	if key in h.handlers {
		handler := h.handlers[key]
		handler(action)!
	} else {
		h.logger.error('unknown actor: ${action.actor}')
	}
}
