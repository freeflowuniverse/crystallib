module downloader

import freeflowuniverse.crystallib.builder

struct Cache {
	nodes []builder.Node
}

[params]
struct DownloadArgs {
	name       string
	version    string
	url        string
	reset      bool
	minsize_kb u32
	caches     []Cache
	hash       bool // means lock will be set and we cannot
}

pub fn download(args DownloadArgs) {
}
