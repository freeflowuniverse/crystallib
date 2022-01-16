module docker

// build ssh enabled alpine docker image
// has default ssh key in there
// pub fn (mut e DockerEngine) build(force bool) ?DockerImage {
// 	mut found := true

// 	if force {
// 		found = false
// 	}

// 	e.image_get('threefold:latest') or { found = false }

// 	if !found {
// 		mut dest := '/tmp/$rand.uuid_v4()'
// 		println('Creating temp dir $dest')
// 		e.node.executor.exec('mkdir $dest') ?

// 		base := 'alpine:3.13'
// 		redis_enable := false

// 		df := docker.dockerfile.replace('\$base', base).replace('redis_enable', '$redis_enable')
// 		e.node.executor.exec("echo '$df' > $dest/dockerfile") ?
// 		e.node.executor.exec("echo '$docker.bootfile' > $dest/boot.sh") ?
// 		println('Building threefold image at $dest/dockerfile')
// 		e.node.executor.exec('cd $dest && docker build -t threefold .') or { panic(err) }
// 	}

// 	return e.image_get('threefold:latest')
// }
