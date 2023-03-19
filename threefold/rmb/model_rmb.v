module rmb

pub struct RmbMessage {
pub mut:
	ver int = 1
	cmd string
	src string
	ref string
	exp u64
	dat string
	dst []u32
	ret string
	now u64
	shm string
}

pub struct RmbError {
pub mut:
	code    int
	message string
}

pub struct RmbResponse {
pub mut:
	ver int = 1
	ref string //todo: define 
	dat string
	dst string //todo: define what is this
	now u64
	shm string //todo: what is this?
	err RmbError
}