module downloader

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.gittools
import os
import json

// pub enum DownloadType {
// 	unknown
// 	git
// 	ssh
// 	pathdir
// 	pathfile
// 	httpfile
// }

// pub struct DownloadMeta {
// pub mut:
// 	args         DownloadArgs
// 	size_kb      u32
// 	hash         string
// 	downloadtype DownloadType
// 	path         string
// }

// [params]
// pub struct ContainerArgs {
// pub mut:
// 	name         string // name of the download, if not specified then last part  of url
// }

// // install runc
// pub fn install() ! {
// 	println('installing runc')
// 	osal

// }
