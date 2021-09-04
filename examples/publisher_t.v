import publisher
import despiegk.crystallib.gittools

fn main() {
	// get publisher, check for all wiki's
	mut gt := gittools.new() or { panic('cannot load gittools:$err') }
	// will only pull if it does not exists

	_ := gt.repo_get_from_url('https://github.com/threefoldtech/info_tftech') or {
		panic('cannot load info_tftech:$err')
	}
	// _ := gt.repo_get_from_url("https://github.com/threefoldfoundation/info_foundation") or {panic ("cannot load repo:$err")}
	// _ := gt.repo_get_from_url("https://github.com/threefoldfoundation/legal") or {panic ("cannot load repo:\n$err")}

	// now we know git repo is there so we can scan the filesystem
	path := '~/code/github/threefoldtech/info_tftech'
	mut f := publisher.new(path) or { panic('cannot load publisher:$err') }

	// println(f.site_locations_get())

	mut site := f.site_get('tftech') or { panic('canot find tftech site,$err') }

	f.check()

	println(f.sites)
	println(site.pages)

	site.load(mut &f)

	// println(site.pages)
}
