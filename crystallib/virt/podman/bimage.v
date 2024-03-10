module podman

import freeflowuniverse.crystallib.osal { exec }
import time
import freeflowuniverse.crystallib.virt.utils
// TODO: needs to be implemented for buildah, is still code from docker

@[heap]
pub struct BAHImage {
pub mut:
	repo    string
	id      string
	id_full string
	tag     string
	digest  string
	size    int // size in MB
	created time.Time
	engine  &CEngine  @[skip; str: skip]
}

// delete podman image
pub fn (mut image BAHImage) delete(force bool) ! {
	mut forcestr := ''
	if force {
		forcestr = '-f'
	}
	exec(cmd: 'podman rmi ${image.id} ${forcestr}', stdout: false)!
}

// export podman image to tar.gz
pub fn (mut image BAHImage) export(path string) !string {
	exec(cmd: 'podman save ${image.id} > ${path}', stdout: false)!
	return ''
}

// import podman image back into the local env
pub fn (mut engine CEngine) load_image(path string) ! {
	exec(cmd: 'podman load < ${path}', stdout: false)!
	engine.images_load()!
}

pub fn (mut e CEngine) images_load() ! {
	e.images = []BAHImage{}
	mut lines := osal.execute_silent("podman images --format '{{.ID}}||{{.Id}}||{{.Repository}}||{{.Tag}}||{{.Digest}}||{{.Size}}||{{.CreatedAt}}'")!
	for line in lines.split_into_lines() {
		fields := line.split('||').map(utils.clear_str)
		if fields.len < 6 {
			panic('podman image needs to output 6 parts.\n${fields}')
		}
		mut image := BAHImage{
			engine: &e
		}
		image.id = fields[0]
		image.id_full = fields[1]
		image.repo = fields[2]
		image.tag = fields[3]
		image.digest = utils.parse_digest(fields[4]) or { '' }
		image.size = utils.parse_size_mb(fields[5]) or { 0 }
		image.created = utils.parse_time(fields[6]) or { time.now() }
		e.images << image
	}
}

@[params]
pub struct ImageGetArgs {
pub:
	repo    string
	tag     string
	digest  string
	id      string
	id_full string
}

pub struct ImageGetError {
	Error
pub:
	args     ImageGetArgs
	notfound bool
	toomany  bool
}

pub fn (err ImageGetError) msg() string {
	if err.notfound {
		return 'Could not find image with args:\n${err.args}'
	}
	if err.toomany {
		return 'Found more than 1 image with args:\n${err.args}'
	}
	panic('unknown error for ImageGetError')
}

pub fn (err ImageGetError) code() int {
	if err.notfound {
		return 1
	}
	if err.toomany {
		return 2
	}
	panic('unknown error for ImageGetError')
}

// find image based on repo and optional tag
// args:
// 	repo string
// 	tag string
// 	digest string
// 	id string
// id_full
pub fn (mut e CEngine) image_get(args ImageGetArgs) !BAHImage {
	mut counter := 0
	mut result_digest := ''

	for i in e.images {
		if i.digest == args.digest {
			return i
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
		if args.id_full != '' && i.id_full != args.id_full {
			continue
		}
		result_digest = i.digest
		counter += 1
		if counter > 1 {
			return ImageGetError{
				args: args
				toomany: true
			}
		}
	}

	if counter == 0 {
		return ImageGetError{
			args: args
			notfound: true
		}
	}
	return e.image_get(digest: result_digest)!
}

pub fn (mut e CEngine) image_exists(args ImageGetArgs) !bool {
	e.image_get(args) or {
		if err.code() == 1 {
			return false
		}
		return err
	}
	return true
}
