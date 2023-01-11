module rmbproxy

import rmbclient

pub interface RMBProxyHandler {
mut:
	rmbc &rmbclient.RMBClient

	handle(string) !string
}

pub struct JobSendHandler {
mut:
	rmbc &rmbclient.RMBClient
}

pub fn (mut h JobSendHandler) handle(data [string]string) !string {
	if not "signature" in data {
		return error("Invalid data: missing signature")
	}
	if not "payload" in data {
		return error("Invalid data: missing payload")
	}

	// TODO decrypt payload using private key
	payload := data["payload"]

	action_job := rmbclient.job_load(payload) or {
		return error("Invalid data: $err")
	}

	h.rmbc.action_schedule(action_job)!

	return ""
}



pub struct TwinSetHandler {
mut:
	rmbc &rmbclient.RMBClient
}

pub fn (mut h TwinSetHandler) handle(data [string]string) !string {
	if not "meta" in data {
		return error("Invalid data: missing meta")
	}

	twin_meta_pub := rmbclient.twinmeta_load(data["meta"]) or {
		return error("Invalid data: $err")
	}

	// TODO add function in client to keep TwinMetaPub info in redis db
	// TODO if twin received has ID higher than the highest, update in DB
	return ""
}



pub struct TwinDelHandler {
mut:
	rmbc &rmbclient.RMBClient
}

pub fn (mut h TwinDelHandler) handle(data [string]string) !string {
	if not "twinid" in data {
		return error("Invalid data: missing twinid")
	}

	twinid := data["twinid"].u32()

	// TODO add function in client to delete 
	return ""
}



pub struct TwinGetHandler {
mut:
	rmbc &rmbclient.RMBClient
}

pub fn (mut h TwinGetHandler) handle(data [string]string) !string {
	if not "twinid" in data {
		return error("Invalid data: missing twinid")
	}

	twinid := data["twinid"].u32()

	// TODO add function in client to get a specific client 
	return 
}



pub struct TwinIdNewHandler {
mut:
	rmbc &rmbclient.RMBClient
}

pub fn (mut h TwinIdNewHandler) handle(data [string]string) !string {
	if not "twinid" in data {
		return error("Invalid data: missing twinid")
	}

	// TODO add function in client to get new ID
	twinid := 
	return twinid
}


pub struct ProxiesGetHandler {
mut:
	rmbc &rmbclient.RMBClient
}

pub fn (mut h ProxiesGetHandler) handle(data [string]string) !string {
	return h.rmbc.iam.rmb_proxy_ips
}
