module models

pub struct ComputeCapacity {
pub mut:
	// cpu cores, minimal 10 cpu_centi_core
	// always reserved with overprovisioning of about 1/4-1/6 //TODO: what does it mean
	cpu u8
	// memory in bytes, minimal 100 MB
	// always reserved
	memory i64
	// min disk size reserved (to make sure you have growth potential)
	// when reserved it means you payment
	// if you use more, you pay for it
}

pub fn (mut c ComputeCapacity) challenge() string {
	mut out := ''
	out += '${c.cpu}'
	out += '${c.memory}'
	return out
}
