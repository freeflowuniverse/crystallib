module zerohub

import net.http
import os

fn test_main() ? {
	mut cl := new(token: os.getenv('HUB_JWT'))!

	flists := cl.get_flists()!
	println(flists)

	// repos := cl.get_repos()!
	// println(repos)

	// files := cl.get_files()!
	// println(files)

	// flists := cl.get_repo_flists('omarabdulaziz.3bot')!
	// println(flists)

	// flist_data := cl.get_flist_dump('omarabdulaziz.3bot', 'omarabdul3ziz-obuntu-zinit.flist')!
	// println(flist_data)

	// mine := cl.get_me()!
	// println(mine.as_map()["status"])

	// flist := cl.get_my_flist("omarabdul3ziz-forum-docker-v3.1.flist")!
	// println(flist)

	// resp := cl.remove_my_flist("threefolddev-presearch-v2.3.flist")!
	// println(resp)

	// res := cl.symlink("mahmoudemmad-mastodon_after_update-test3.flist", "testsymlink")!
	// println(res)

	// res := cl.cross_symlink("abdelrad", "0-hub.flist", "testcrosssymlink")!
	// println(res)

	// res := cl.rename("omarabdul3ziz-forum-docker-v3.1.flist", "renamed")!
	// println(res)

	// res := cl.promote("abdelrad", "0-hub.flist", "promoted")!
	// println(res)

	// res := cl.convert("alpine")!
	// println(res)

	// res := cl.merge_flists( ["omarabdulaziz.3bot/omarabdul3ziz-obuntu-zinit.flist", "omarabdulaziz.3bot/omarabdul3ziz-peertube-v3.1.1.flist"], "merged")!
	// println(res)

	// res := cl.upload_flist("./testup.flist")!
	// println(res)

	// res := cl.upload_archive('./alpine.tar.gz')!
	// println(res)
}
