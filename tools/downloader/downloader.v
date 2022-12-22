module downloader

import freeflowuniverse.crystallib.builder

struct Cache{
	nodes []builder.Node

}

struct DownloadArgs{
	name 		string
	version 	string
	url 		string
	reset 		bool
	minsize_kb 	u32
	caches 		[]
	hash	    bool //means lock will be set and we cannot 
}

pub fn download(args DownloadArgs){


}