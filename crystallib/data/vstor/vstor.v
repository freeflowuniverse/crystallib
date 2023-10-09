module vstor

import freeflowuniverse.crystallib.core.pathlib
import time

pub struct VSTOR {
pub mut:
	zdbs           []ZDB
	current_spread ZDBCurrentSpread
}

// is the current spread as used when storing new data to ZDB's
pub struct ZDBCurrentSpread {
pub mut:
	spread           []u32 // zdb's we are using
	parts            u8    // nr of parts data needs to be cut in e.g. 16
	parity           u8    // size of parity e.g. 4
	last_check       time.Time
	slice_size_kb    u32 // default 4 MB
	compression_type CompressionType
	encryption_type  EncryptionType
}

// walk over the zdb stats, figure out which zdb's are best return those
pub fn (mut vstor VSTOR) spread_get(zdbid u32) !ZDBCurrentSpread {
	// ony use new measurements every 60 minutes
	// check if last_check is older than 60 minutes, if so then walk over all zdb_stats (in mem, do not use reality)
	// based on info in mem, return the most optimal spread
	// based on latency and size free on disks
	// need to make sure the nodes are in separate locations

	// maintain all properties as defined before only change the ZDB's

	mut spread := ZDBCurrentSpread{}
	return spread
}

// cut file in slices depending the current_spread
// encode & store the parts in the ZStor
pub fn (mut vstor VSTOR) stor(mut path pathlib.Path) ! {
	if !path.exists() {
		return error('make sure path exists to stor: ${path.path}')
	}
}

// start a thread which will every hour do a check of all the known ZDBs
// info will be cached in redis
// eventually we will monitor other things too, so we know when system is no longer good
pub fn (mut vstor VSTOR) monitor() ! {
	// when start and stats are not known, check if they are in redis
	// if not in redis do the check
	// do this every 1h
}

// download file as specified to specified path
fn (mut vstor VSTOR) get(mut f FileMeta, path0 string) ! {
	// mut path := pathlib.get(path0)!
}
