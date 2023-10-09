module nostr

import threefoldtech.threebot.nostr as nostr_client { NostrClient }
import freeflowuniverse.crystallib.baobab.actions { Action }
import freeflowuniverse.crystallib.rpcwebsocket { RpcWsClient }
import log { Logger }

pub struct NostrHandler {
pub mut:
	client NostrClient
	logger Logger
}

pub fn new(mut rpc_client RpcWsClient, logger Logger) NostrHandler {
	mut cl := nostr_client.new(mut rpc_client)

	return NostrHandler{
		client: cl
		logger: logger
	}
}

pub fn (mut n NostrHandler) handle_action(action Action) ! {
	match action.actor {
		'channel' {
			n.channel(action)!
		}
		'direct' {
			n.direct(action)!
		}
		else {
			return error('actor ${action.actor} is not supported')
		}
	}
}
