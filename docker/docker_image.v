module docker

// import freeflowuniverse.crystallib.builder
import time

[heap]
pub struct DockerImage {
pub mut:
	repo    string
	id      string
	tag     string
	digest  string
	size    int // size in MB
	created time.Time
	engine  &DockerEngine [str: skip]
}

// delete docker image
pub fn (mut image DockerImage) delete(force bool) ! {
	mut forcestr := ''
	if force {
		forcestr = '-f'
	}
	image.engine.node.exec_silent('docker rmi ${image.id} ${forcestr}')!
	mut x := 0
	for image2 in image.engine.images {
		if image2.id == image.id {
			image.engine.images.delete(x)
		}
		x += 1
	}
}

// export docker image to tar.gz
pub fn (mut image DockerImage) export(path string) !string {
	return image.engine.node.exec_silent('docker save ${image.id} > ${path}')
}

// import docker image back into the local env
pub fn (mut image DockerImage) load(path string) !string {
	return image.engine.node.exec_silent('docker load < ${path}')
}

pub fn (mut e DockerEngine) images_load() ! {
	e.images = []DockerImage{}
	mut lines := e.node.exec_silent("docker images --format '{{.ID}}|{{.Repository}}|{{.Tag}}|{{.Digest}}|{{.Size}}|{{.CreatedAt}}'")!
	for line in lines.split_into_lines() {
		fields := line.split('|').map(clear_str)
		mut obj := DockerImage{
			engine: &e
		}
		obj.id = fields[0]
		obj.digest = parse_digest(fields[3]) or { '' }
		obj.size = parse_size_mb(fields[4]) or { 0 }
		obj.created = parse_time(fields[5]) or { time.now() }
		e.images << obj
	}
}

[params]
pub struct ImageGetArgs {
pub:
	repo   string
	tag    string
	digest string
	id     string
}

// find image based on repo and optional tag
// args:
// 	repo string
// 	tag string
// 	digest string
// 	id string
pub fn (mut e DockerEngine) image_get(args ImageGetArgs) !&DockerImage {
	mut counter := 0
	mut result_digest := ''
	for i in e.images {
		if args.digest == args.digest {
			return &i
		}
		if args.digest != '' {
			continue
		}
		if args.repo != '' && i.repo != args.repo {
			continue
		}
		if args.tag != '' && i.tag != args.tag {
			continue
		}
		if args.id != '' && i.id != args.id {
			continue
		}
		result_digest = i.digest
		counter += 1
	}
	if counter > 0 {
		return error('found more than one image for ${args}')
	}
	if counter == 0 {
		return error("didn't find an image for ${args}")
	}
	return e.image_get(digest: result_digest)!
}
