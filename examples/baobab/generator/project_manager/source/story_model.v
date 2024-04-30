module source

pub struct Story {
pub:
	id string
	name string @[required]
	tag string @[index]
}