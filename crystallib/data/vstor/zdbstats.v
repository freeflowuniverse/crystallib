module vstor

// import freeflowuniverse.crystallib.core.pathlib
import time

enum ZDBSTATUS {
	unreachable
	ok
	error
}

pub struct ZDBSTAT {
pub mut:
	id           u32 // links to id of ZDB in VSTOR.zdbs
	measurements []ZDBMeasurement
}

pub struct ZDBMeasurement {
pub mut:
	status              ZDBSTATUS
	latencies           u32 // in millisecs
	storage_capacity_gb u32 // amount of data stored in GB
	storage_used_gb     u32 // amount of data used in the zdb
	time                time.Time
}

pub fn (mut vstor VSTOR) zdbstats_check() ! {
	// start upto 20 threads for doing the checks towards each ZDB
	// add a ZDMEASUREMENT every time we do it
	// keep upto 12 checks
	// use ZDBSTAT.check()... in threads
}

// return ZDBSTAT object
pub fn (mut vstor VSTOR) zdbstats_get(zdbid u32) !ZDBSTAT {
	return ZDBSTAT{}
}

// execute on a check, remote poll the ZDB which returns the info
// only keep 12 checks
pub fn (mut stat ZDBSTAT) check() ! {
}

// return latency averaged
pub fn (mut stat ZDBSTAT) latency() u32 {
	return 0
}

pub fn (mut stat ZDBSTAT) storage_capacity() u32 {
	return 0
}

pub fn (mut stat ZDBSTAT) storage_used() u32 {
	return 0
}

// return 100 for full, 0 for empty, 10 for 10%
pub fn (mut stat ZDBSTAT) percent_free() u8 {
	return 0
}

pub fn (mut stat ZDBSTAT) cache_set() ! {
	// store the info in redis local
}

pub fn (mut stat ZDBSTAT) cache_get() ! {
	// store the info in redis local
}

pub fn cache_get(zdb u32) !ZDBSTAT {
	// see if in redis we have the info, if yes return if no create new one which will be empty
	return ZDBSTAT{}
}
