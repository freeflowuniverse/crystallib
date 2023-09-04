module hero

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.gittools
import os
import json

pub enum DownloadType {
	unknown
	git
	ssh
	pathdir
	pathfile
	httpfile
}

pub struct DownloadMeta {
pub mut:
	args         DownloadArgs
	size_kb      u32
	hash         string
	downloadtype DownloadType
	path         string
}

[params]
pub struct DownloadArgs {
pub mut:
	name         string // name of the download, if not specified then last part  of url
	downloadpath string // the directory or file where we will download, will be /tmp/downloads/$name
	url          string // url can be ssh:// http(s):// git:// file:// path:// http(s)file://
	reset        bool   // to remove all changes
	// gitpull    bool   // if you want to force to pull the information
	minsize_kb u32 // is always in kb
	maxsize_kb u32
	dest       string // if the dir or file needs to be copied somewhere
	destlink   bool = true // if bool then will link the downloaded content to the dest
	hash       string // if specified then will check the hash of the downloaded content
}

// downoads url specified dir or file .
// url can be ssh:// http(s):// git:// file:// path:// http(s)file:// .
// to a directory linked to a circle '${runner.root}/circles/${circlename}/downloads/${args.name}' .
// will return DownloadMeta, which is als json serialized in above directory .
// if dest specified will link to the dest or copy depending param:destlink
pub fn download(args_ DownloadArgs) !DownloadMeta {
	mut args := args_

	mut lastname := args.url.split('/').last()
	if lastname.contains('?') {
		return error('cannot get name from url if ? in the last part after /')
	}

	mut ext := ''
	if lastname.contains('.') {
		ext = lastname.split('.').last().to_lower().trim_space()
		if ext.len > 4 {
			ext = ''
		}
	}

	if args.name == '' {
		args.name = texttools.name_fix(lastname)
	}

	if args.name == '' {
		return error('last name should not be empty when downloading.\n${args}')
	}

	if args.dest.contains('@name') {
		args.dest = args.dest.replace('@name', args.name)
	}
	if args.url.contains('@name') {
		args.url = args.url.replace('@name', args.name)
	}

	if args.downloadpath == '' {
		args.downloadpath = '${os.temp_dir()}/downloads/${args.name}'
	}

	println(args)

	// mut downloaddir := '${r.root.path}/circles/${r.circle}/downloads/${args.name}'

	mut downloadpath := pathlib.get(args.downloadpath)

	u := args.url.to_lower().trim_space()

	mut downloadtype := DownloadType.unknown

	if u.starts_with('http://') || u.starts_with('https://') || u.starts_with('git://') {
		// might be git based checkout
		mut gs := gittools.get(light: true)!
		mut gr := gs.repo_get_from_url(url: args.url, pull: args.reset, reset: args.reset)!
		downloadpath = pathlib.get_dir(gr.path_content_get(), false)!
		downloadtype = .git
	} else if u.starts_with('ssh://') || u.starts_with('ftp://') {
		return error('Cannot download for runner, unsupported methods:\n${args}')
	} else if u.starts_with('httpsfile') || u.starts_with('httpfile') {
		mut urllocal := args.url.replace('httpsfile', 'https')
		urllocal = args.url.replace('httpfile', 'http')
		defer {
			downloadpath.delete() or { panic(err) }
		}
		_ := osal.download(
			url: urllocal
			reset: args.reset
			dest: downloadpath.path
			minsize_kb: args.minsize_kb
			maxsize_kb: args.maxsize_kb
		)!
		downloadtype = .httpfile
	} else if args.url.len > 0 {
		downloadpath = pathlib.get(args.url)
		if downloadpath.is_file() {
			downloadtype = .pathfile
		} else if downloadpath.is_dir() {
			downloadtype = .pathdir
		} else {
			return error("Can only download files or dirs.\n${args}'")
		}
	}

	if !downloadpath.exists() {
		return error("Cannot download, downloaded dir does not exist: '${downloadpath.path}':\n${args}")
	}

	md5hex := downloadpath.md5hex()!
	size_kb := downloadpath.size_kb()!

	if args.minsize_kb > 0 && size_kb < args.minsize_kb {
		return error("Cannot download for runner, min size requirement not met (${size_kb} -> min:${args.minsize_kb}): '${downloadpath.path}':\n${args}")
	}
	if args.maxsize_kb > 0 && size_kb > args.maxsize_kb {
		return error("Cannot download for runner, max size requirement not met (${size_kb} -> min:${args.maxsize_kb}): '${downloadpath.path}':\n${args}")
	}
	mut metaobj := DownloadMeta{
		args: args
		size_kb: u32(size_kb)
		hash: md5hex
		downloadtype: downloadtype
		path: downloadpath.path
	}
	metapath := '${downloadpath.path_dir()}/.meta'
	mut metafile := downloadpath.file_get_new(metapath)!
	metaobj_data := json.encode_pretty(metaobj)
	metafile.write(metaobj_data)!
	if args.dest.len > 0 && args.dest != downloadpath.path {
		// means we need to link or copy the downloaded content to a different location
		println(' - downloader dest link: ${args.dest}')
		if downloadpath.is_file() {
			// means its a file need to link differently
			if args.destlink {
				downloadpath.link(args.dest, true)!
			} else {
				mut desto := pathlib.get(args.dest)
				downloadpath.copy(mut desto)!
			}
		} else {
			if args.destlink {
				downloadpath.link(args.dest, true)!
			} else {
				mut desto := pathlib.get(args.dest)
				downloadpath.copy(mut desto)!
			}
		}
	}
	println(metaobj)
	return metaobj
}
