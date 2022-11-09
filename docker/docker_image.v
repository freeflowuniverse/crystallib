module docker

import freeflowuniverse.crystallib.builder
import time

[heap]
pub struct DockerImage {
pub mut:
	repo    string
	tag     string
	id      string
	digest  string
	size    int // size in MB
	created time.Time
	node    string
}

// delete docker image
pub fn (mut image DockerImage) delete(force bool) !string {
	mut factory := builder.new()
	mut node := factory.node_get(image.node)!
	if force {
		return node.exec_silent('docker rmi -f $image.id')
	}
	return node.exec_silent('docker rmi $image.id')
}

// export docker image to tar.gz
pub fn (mut image DockerImage) export(path string) !string {
	mut factory := builder.new()
	mut node := factory.node_get(image.node)!
	return node.exec_silent('docker save $image.id > $path')
}

// import docker image back into the local env
pub fn (mut image DockerImage) load(path string) !string {
	mut factory := builder.new()
	mut node := factory.node_get(image.node)!
	return node.exec_silent('docker load < $path')
}
