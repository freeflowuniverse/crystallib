module rmbclient

import freeflowuniverse.crystallib.actionparser
import freeflowuniverse.crystallib.params { Params }
import time
import os
import json
import rand


enum ActionJobState {
	init
	tostart
	recurring
	scheduled
	active
	done
	error
}


//actionjob as how its being send & received from bus
struct ActionJobPublic {
	guid        string 	//unique jobid (unique per actor which is unique per twin)
	twinid		 u32    //which twin needs to execute the action
	action   	 string 	//actionname in long form includes domain & actor
	params       string
	state        string
	start        i64		//epoch
	end          i64		//epoch
	grace_period u32 		//wait till next run, in seconds
	error        string		//string description of what went wrong
	timeout      u32 		//time in seconds, 2h is maximum
	src_twinid		 u32    //which twin was sending the job
	src_action      string	//unique actor id, runs on top of twin
	dependencies []string
}

pub struct ActionJob {
pub mut:
	guid        string 	//unique jobid (unique per actor which is unique per twin)
	twinid		 u32    //which twin needs to execute the action
	action   	 string //actionname in long form includes domain & actor $domain.$actor.$action
	params       Params
	state        ActionJobState
	start        time.Time
	end          time.Time
	grace_period u32  //wait till next run
	error        string
	timeout      u32 // time in seconds, 2h is maximum
	src_twinid		 	u32    //which twin is responsible for executing on behalf of actor
	src_action      	string	//unique actor id, runs on top of twin
	dependencies []string
}

pub fn (job ActionJob) dumps() !string{
	params_data:=json.encode(job.params)
	mut statestr:=""
	match job.state{
		.init {statestr="init"}
		.tostart{statestr="tostart"}
		.recurring{statestr="recurring"}
		.scheduled{statestr="scheduled"}
		.active{statestr="active"}
		.done{statestr="done"}
		.error{statestr="error"}
	}		
	mut job2:=ActionJobPublic{
		twinid:job.twinid
		action:job.action
		params:params_data
		state:statestr
		start:job.start.unix_time() 
		end:job.end.unix_time()
		grace_period:job.grace_period
		error:job.error
		timeout:job.timeout
		guid:job.guid
		src_twinid:job.src_twinid
		src_action:job.src_action	
	}
	job2_data:=json.encode(job2)
	return job2_data
}

//json data for ActionJobPublic
//
// fields:
//	   twinid		u32    //which twin needs to execute the action
//	   action   	string 	//actionname in long form includes domain & actor
//     params       string
//     state        string
//     start        u64		//epoch
//     end          u64		//epoch
//     grace_period u32 		//wait till next run, in seconds
//     error        string		//string description of what went wrong
//     timeout      u32 		//time in seconds, 2h is maximum
//     guid        u32 	//unique jobid (unique per actor which is unique per twin)
//     src_twinid		 u32    //which twin is responsible for executing on behalf of actor (0 is local)
//     src_action      u16	//unique actor id, runs on top of twin
//
pub fn job_load(data string)! ActionJob{
	job:=json.decode(ActionJobPublic,data) or {return error("Could not json decode: $data .\nError:$err")}
	params:=json.decode(Params,job.params) or {return error("Could not json decode for params: $job.params \nError:$err")}
	mut statecat:=ActionJobState.init	
	match job.state{
		"init" 		{statecat=.init}
		"tostart" 	{statecat=.tostart}
		"recurring" {statecat=.recurring}
		"scheduled" {statecat=.scheduled}
		"active" 	{statecat=.active}
		"done" 		{statecat=.done}
		"error" 	{statecat=.error}
		else{	return error("Could not find job state, needs to be init, tostart, recurring, scheduled, active, done, error")}
	}
	mut jobout:=ActionJob{
		twinid:job.twinid
		action:job.action
		params:params
		state:statecat
		start:time.unix(job.start)
		end:time.unix(job.end)
		grace_period:job.grace_period
		error:job.error
		timeout:job.timeout
		guid:job.guid
		src_twinid:job.src_twinid
		src_action:job.src_action
	}
	return jobout
}

