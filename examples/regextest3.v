import regex

fn main() {
	mut text := '
	[core]
			repositoryformatversion = 0
			filemode = true
			bare = false
			logallrefupdates = true
			ignorecase = true
			precomposeunicode = true
	[remote "origin"]
			url = https://github.com/crystaluniverse/crystaltools
			fetch = +refs/heads/*:refs/remotes/origin/*
	[branch "master"]
			remote = origin
			merge = refs/heads/master

	'

	query := r'url *= *https:.*'
	mut re := regex.regex_opt(query) or { panic(err) }

	mut gi := 0
	all := re.find_all(text)
	println(all)
	for gi < all.len {
		println('RESULT:')
		println('${text[all[gi]..all[gi + 1]]}')
		gi += 2
	}

	println('OTHER TEST')

	// OTHER TEST
	start, end := re.match_string(text)
	if start >= 0 {
		println('[$start,$end] [${re.get_group_by_id(text, 0)}]')
	} else {
		println('# Not Found!')
	}
}
