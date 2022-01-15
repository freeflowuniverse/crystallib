module docker

import builder

pub struct DockerImage {
pub mut:
	repo    string
	tag     string
	id      string
	digest	string
	size    int //size in MB
	created string
}

// delete docker image
pub fn (mut image DockerImage) delete(force bool) ?string {
	if force {
		return image.node.executor.exec_silent('docker rmi -f $image.id')
	}
	return image.node.executor.exec_silent('docker rmi $image.id')
}

// export docker image to tar.gz
pub fn (mut image DockerImage) export(path string) ?string {
	return image.node.executor.exec_silent('docker save $image.id > $path')
}

// import docker image back into the local env
pub fn (mut image DockerImage) load(path string) ?string {
	return image.node.executor.exec_silent('docker load < $path')
}
