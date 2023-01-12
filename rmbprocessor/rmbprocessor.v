module rmbprocessor

import freeflowuniverse.crystallib.rmbclient

import log
import time

pub struct RMBProcessor{
pub mut:
	rmbc rmbclient.RMBClient
	rmbpc RMBProxyClient
	logger &log.Logger
}

pub fn new(logger &log.Logger) !RMBProcessor {
	mut rmbc := rmbclient.new()!
	mut rmbpc := new_rmbproxyclient(rmbc.twinid, rmbc.rmb_proxy_ips, logger)!
	mut rmbp := RMBProcessor {
		rmbc: rmbc
		rmbpc: rmbpc
		logger: unsafe { logger }
	}
	return rmbp
}

//if rmbid is 0, means we work in local mode
// 		src_twinid		 u32    //which twin is responsible for executing on behalf of actor (0 is local)
// 		src_rmbids		 []u32  //how do we find our way back, if 0 is local, can be more than 1
// 		ipaddr			 string
fn (mut rmbp RMBProcessor) process() ! {
	mut rmbc := &rmbp.rmbc
	mut rmbpc := &rmbp.rmbpc
	mut guid := ""
	
	// run proxyclient on new thread
	job_channel := chan rmbclient.ActionJob{}
	t_proxy_client := spawn rmbpc.run(job_channel)

	for {
		guid = rmbc.next_job_guid() or {
			rmbp.logger.error("$err")
			return error("error in jobs queue")
		}
		if guid.len > 0 {
			rmbp.logger.info("New job: $guid")
			mut job := rmbc.job_get(guid)!
			rmbp.logger.debug("$job")
			if job.twinid==u32(0) || job.twinid==rmbc.twinid {
				rmbp.logger.info("Job is meant for me, lets handle it")
				rmbc.reschedule_in(guid)!
			} else {
				rmbp.logger.info("Job is meant for someone else, lets send it to the proxy")
				job_channel <- job
			}
		}
		rmbp.logger.debug("Sleep")
		time.sleep(time.second)
	}

	t_proxy_client.wait()!
}

//run the rmb processor
pub fn process(logger &log.Logger)!{
	mut rmbp := new(logger)!
	rmbp.process()!
}