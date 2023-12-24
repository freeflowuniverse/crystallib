module models

pub struct ComputeCapacity {
pub mut:
	// cpu cores
	cpu u8
	// memory in bytes, minimal 100 MB
	memory i64
}

pub fn (mut c ComputeCapacity) challenge() string {
	mut out := ''
	out += '${c.cpu}'
	out += '${c.memory}'
	return out
}
