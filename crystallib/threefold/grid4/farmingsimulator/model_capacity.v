module farmingsimulator

import math

// https://library.threefold.me/info/threefold/#/tfgrid/resource_units
pub struct ResourceUnits {
pub mut:
	cru f64 // 1 logical core
	mru f64 // 1 GB of memory
	hru f64 // 1 GB of HD
	sru f64 // 1 GB of SSD
}

// cu = min((mru - 1) / 4, cru * 4 / 2, sru / 50)
// su = hru / 1200 + sru * 0.8 / 200
// https://library.threefold.me/info/threefold/#/tfgrid/farming/cloudunits
pub struct CloudUnits {
pub mut:
	cu f64
	su f64
	nu f64 // GB per month
}

// this is the calculation as result of defining the node template
@[heap]
pub struct FarmingCapacity {
pub mut:
	resourceunits ResourceUnits
	cloudunits    CloudUnits
	cost          f64
	// consumption for 1 node in watt
	power f64
	// expressed in U, there are 44 in 1 rack
	rackspace f64
}

fn cloudunits_calc(ru ResourceUnits) CloudUnits {
	mut cu := 0.0
	mut su := 0.0
	cu = math.min((ru.mru - 1) / 4, ru.cru * 4 / 2)
	cu = math.min(cu, ru.sru / 50) // make sure that we have enough SSD
	su = ru.hru / 1200 + ru.sru * 0.8 / 200
	cloudunits := CloudUnits{
		cu: cu
		su: su
	}
	return cloudunits
}
