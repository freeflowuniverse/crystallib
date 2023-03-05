module rmbproxy

import freeflowuniverse.crystallib.redisclient
import json

pub interface RMBProxyMessageHandler {
mut:
	rmbp &RMBProxy
	handle(mut client websocket.Client, data map[string]string) !
}

pub struct JobSendHandler {
mut:
	rmbp &RMBProxy
}

pub fn (mut h JobSendHandler) handle(mut client websocket.Client, data map[string]string) ! {
	if 'signature' !in data {
		return error('Invalid data: missing signature')
	}
	if 'payload' !in data {
		return error('Invalid data: missing payload')
	}
	if 'dsttwinid' !in data {
		return error('Invalid data: dsttwinid not set')
	}

	dsttwinid := data['dsttwinid'].u32()

	if dsttwinid !in h.rmbp.clients {
		return error('Unknown client with twinid ${dsttwinid}')
	}

	h.rmbp.clients[dsttwinid].write(data, .binary_frame)!
}

pub struct TwinSetHandler {
mut:
	rmbp &RMBProxy
}

pub fn (mut h TwinSetHandler) handle(mut client websocket.Client, data map[string]string) ! {
	if 'meta' !in data {
		return error('Invalid data: missing meta')
	}
	if 'twinid' !in data {
		return error('Invalid data: missing twinid')
	}

	twinid := data['twinid'].u32()
	max_twinid := h.rmbp.redis.get('rmb.twins.max_twin_id')!.u32()
	if max_twinid < twinid {
		h.rmbp.redis.set('rmb.twins.max_twin_id', data['twinid'])!
	}
	h.rmbp.redis.hset('rmb.twins', data['twinid'], data['meta'])!
	rmbp.clients[twinid] = client
}

pub struct TwinDelHandler {
mut:
	rmbp &RMBProxy
}

pub fn (mut h TwinDelHandler) handle(mut client websocket.Client, data map[string]string) ! {
	if 'twinid' !in data {
		return error('Invalid data: missing twinid')
	}

	h.rmbp.redis.hdel('rmb.twins', data['twinid'])!
	rmbp.clients.delete(data['twinid'].u32())
}

pub struct TwinGetHandler {
mut:
	rmbp &RMBProxy
}

pub fn (mut h TwinGetHandler) handle(mut client websocket.Client, data map[string]string) ! {
	if 'twinid' !in data {
		return error('Invalid data: missing twinid')
	}

	meta := h.rmbp.redis.hget('rmb.twins', data['twinid'])!

	client.write(meta, .binary_frame)!
}

pub struct TwinIdNewHandler {
mut:
	rmbp &RMBProxy
}

pub fn (mut h TwinIdNewHandler) handle(mut client websocket.Client, data map[string]string) ! {
	if 'twinid' !in data {
		return error('Invalid data: missing twinid')
	}

	mut max_twinid := h.rmbp.redis.get('rmb.twins.max_twin_id')!.u32()
	max_twinid += 1

	// send back max_twin_id
}

pub struct ProxiesGetHandler {
mut:
	rmbp &RMBProxy
}

pub fn (mut h ProxiesGetHandler) handle(mut client websocket.Client, data map[string]string) ! {
	// todo send proxies
	// return json.encode(h.rmbc.rmb_proxy_ips)
}
