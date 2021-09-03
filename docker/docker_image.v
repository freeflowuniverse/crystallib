module docker

import despiegk.crystallib.builder

pub struct DockerImage {
pub mut:
	repo    string
	tag     string
	id      string
	size    f64
	created string
	node    builder.Node
}

// delete docker image
pub fn (mut image DockerImage) delete(force bool) ?string {
	if force {
		return image.node.executor.exec('docker rmi -f $image.id')
	}
	return image.node.executor.exec('docker rmi $image.id')
}

// export docker image to tar.gz
pub fn (mut image DockerImage) export(path string) ?string {
	return image.node.executor.exec('docker save $image.id > $path')
}

// import docker image back into the local env
pub fn (mut image DockerImage) load(path string) ?string {
	return image.node.executor.exec('docker load < $path')
}
