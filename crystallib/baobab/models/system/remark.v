module system

import freeflowuniverse.crystallib.data.ourtime

[heap]
struct Remarks {
pub mut:
	// list of remarks which are linked to the object, the data are smartid's in int form
	remarks []u32
}

[heap]
struct Remark {
pub mut:
	content string
	time    ourtime.OurTime
	author  string // smartid to circle.person
}
