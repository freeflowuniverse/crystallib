module publisher_core
// get all static files from internet
pub fn (mut config ConfigRoot) update_staticfiles(force bool) ? {
	println('Updating Javascript files in cache')
	mut p := os.join_path(config.publish.paths.base, 'static')
	process.execute_silent('mkdir -p $p') or { panic('can not create dir $p') }
	for file, link in config.staticfiles {
		mut dest := os.join_path(p, file)
		if !os.exists(dest) || (os.exists(dest) && force) {
			cmd := 'curl --connect-timeout 5 --max-time 10 --retry 5 --retry-delay 0 --retry-max-time 60 -L -o $dest $link'
			// println(cmd)
			process.execute_silent(cmd) or {
				panic(' *** WARNING: can not  download $link to ${dest}. \n$cmd')
				continue
			}
			println(' - downloaded $link')
		}
	}
}
