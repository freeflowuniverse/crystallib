module rmbproxy

import freeflowuniverse.crystallib.rmbclient
import freeflowuniverse.crystallib.rmbprocessor

import json

pub interface RMBProxyHandler {
mut:
	rmbc &rmbclient.RMBClient

	handle(data map[string]string) !string
}

pub struct JobSendHandler {
mut:
	rmbc &rmbclient.RMBClient
}

pub fn (mut h JobSendHandler) handle(data map[string]string) !string {
	if !("signature" in data) {
		return error("Invalid data: missing signature")
	}
	if !("payload" in data) {
		return error("Invalid data: missing payload")
	}

	// TODO decrypt payload using private key
	payload := data["payload"]

	mut action_job := rmbclient.job_load(payload) or {
		return error("Invalid data: $err")
	}

	h.rmbc.action_schedule(mut action_job)!

	return ""
}



pub struct TwinSetHandler {
mut:
	rmbc &rmbclient.RMBClient
}

pub fn (mut h TwinSetHandler) handle(data map[string]string) !string {
	if !("meta" in data) {
		return error("Invalid data: missing meta")
	}

	twin_meta_pub := json.decode(rmbprocessor.TwinMetaPub, data["meta"]) or {
		return error("Invalid data: $err")
	}

	h.rmbc.set_twin(twin_meta_pub.twinid, data["meta"])!

	return ""
}



pub struct TwinDelHandler {
mut:
	rmbc &rmbclient.RMBClient
}

pub fn (mut h TwinDelHandler) handle(data map[string]string) !string {
	if !("twinid" in data) {
		return error("Invalid data: missing twinid")
	}

	twinid := data["twinid"].u32()

	h.rmbc.del_twin(twinid)!

	return ""
}



pub struct TwinGetHandler {
mut:
	rmbc &rmbclient.RMBClient
}

pub fn (mut h TwinGetHandler) handle(data map[string]string) !string {
	if !("twinid" in data) {
		return error("Invalid data: missing twinid")
	}

	twinid := data["twinid"].u32()

	twin := h.rmbc.get_twin(twinid)!

	return twin
}



pub struct TwinIdNewHandler {
mut:
	rmbc &rmbclient.RMBClient
}

pub fn (mut h TwinIdNewHandler) handle(data map[string]string) !string {
	if !("twinid" in data) {
		return error("Invalid data: missing twinid")
	}

	twinid := h.rmbc.new_twin_id()!
	
	return twinid.str()
}


pub struct ProxiesGetHandler {
mut:
	rmbc &rmbclient.RMBClient
}

pub fn (mut h ProxiesGetHandler) handle(data map[string]string) !string {
	return json.encode(h.rmbc.rmb_proxy_ips)
}
