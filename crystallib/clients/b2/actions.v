module b2

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.ui.console
import json
import os
import time
// res:=py.exec(cmd:cmd)!

fn (mut self B2Client[Config]) pycode_init() !string {
	mut cfg := self.config_get()!
	c := "
		import json
		from b2sdk.v2 import *
		info = InMemoryAccountInfo()
		b2_api = B2Api(info)
		b2_api.authorize_account(\"production\", \"${cfg.keyid}\", \"${cfg.appkey}\")
		"
	return texttools.dedent(c)
}

fn (mut self B2Client[Config]) check_installed() ! {
	needed := 'b2sdk,ipython'
	for item in texttools.to_array(needed) {
		self.py.pip(item)!
		// if !self.py.pips_done_check(item) {
		// }
	}
}

pub struct BucketData {
pub:
	id    string
	type_ string
	name  string
}

pub fn (mut self B2Client[Config]) list_buckets() ![]BucketData {
	self.check_installed()!
	code0 := self.pycode_init()!
	mut code := '
	res=b2_api.list_buckets()
	res2=[]
	for x in res:
    	res2.append({"id":x.id_,"type_":x.type_,"name":x.name})
	console.print_debug("==RESULT==")
	console.print_debug(json.dumps(list(res2), indent=4))	
	'
	code = code0 + '\n' + texttools.dedent(code)

	res := self.py.exec(cmd: code)!
	r := json.decode([]BucketData, res)!
	return r
}

@[params]
pub struct UploadArgs {
pub mut:
	src        string
	dest       string
	bucketname string
}

pub fn (mut self B2Client[Config]) upload(args_ UploadArgs) ! {
	mut args := args_
	mut cfg := self.config_get()!

	if !os.exists(args.src) {
		return error('cannot upload ${args.src} to b2 client with name: ${self.instance}')
	}
	if args.dest == '' {
		args.dest = os.base(args.src)
	}
	if args.bucketname == '' {
		args.bucketname = cfg.bucketname
	}
	self.check_installed()!
	code0 := self.pycode_init()!
	mut code := '
	bucket = b2_api.get_bucket_by_name("${args.bucketname}")
	bucket.upload_local_file(
			local_file="${args.src}",
			file_name="${args.dest}"
		)
	'
	code = code0 + '\n' + texttools.dedent(code)

	console.print_debug('upload b2:${self.instance}\n${args}')
	self.py.exec(cmd: code, stdout: true)!
}

// download
@[params]
pub struct DownloadArgs {
pub mut:
	file_name  string
	dest       string
	bucketname string
}

pub fn (mut self B2Client[Config]) download(args_ DownloadArgs) ! {
	mut args := args_
	mut cfg := self.config_get()!

	if !os.exists(os.dir(args.dest)) {
		return error("cannot download ${args.file_name} to local file system: ${os.dir(args.dest)} doesn't exist")
	}
	if args.bucketname == '' {
		args.bucketname = cfg.bucketname
	}
	self.check_installed()!
	code0 := self.pycode_init()!
	mut code := '
	bucket = b2_api.get_bucket_by_name("${args.bucketname}")
	downloaded_file = bucket.download_file_by_name("${args.file_name}")
	downloaded_file.save_to("${args.dest}")
	'
	code = code0 + '\n' + texttools.dedent(code)

	console.print_debug('download b2:${self.instance}\n${args}')
	self.py.exec(cmd: code, stdout: true)!
}

// bucket type enum
pub enum BucketType {
	allpublic
	allprivate
}

// Implement the to_string method for the Fruit enum
pub fn (bt BucketType) to_string() string {
	match bt {
		.allpublic { return 'allPublic' }
		.allprivate { return 'allPrivate' }
	}
}

// create Bucket
@[params]
pub struct CreateBucketArgs {
pub mut:
	bucketname string
	buckettype BucketType
}

pub fn (mut self B2Client[Config]) create_bucket(args_ CreateBucketArgs) ! {
	mut args := args_
	mut cfg := self.config_get()!
	if args.bucketname == '' {
		args.bucketname = cfg.bucketname
	}
	self.check_installed()!
	code0 := self.pycode_init()!
	mut code := '
	b2_api.create_bucket("${args.bucketname}", "${args.buckettype.to_string()}")
	'
	code = code0 + '\n' + texttools.dedent(code)

	console.print_debug('create Bucket b2:${self.instance}\n${args}')
	self.py.exec(cmd: code, stdout: true)!
}

// Delete Bucket
@[params]
pub struct DeleteBucketArgs {
pub mut:
	bucketname string
}

pub fn (mut self B2Client[Config]) delete_bucket(args_ DeleteBucketArgs) ! {
	mut args := args_
	mut cfg := self.config_get()!
	if args.bucketname == '' {
		args.bucketname = cfg.bucketname
	}
	self.check_installed()!
	code0 := self.pycode_init()!
	mut code := '
	bucket = b2_api.get_bucket_by_name("${args.bucketname}")
	b2_api.delete_bucket(bucket)
	'
	code = code0 + '\n' + texttools.dedent(code)

	console.print_debug('delete Bucket b2:${self.instance}\n${args}')
	self.py.exec(cmd: code, stdout: true)!
}

pub struct ListBucketArgs {
	bucketname string
}

pub struct BucketFile {
	file_name        string
	upload_timestamp time.Time
}

pub fn (mut self B2Client[Config]) list_files(args_ ListBucketArgs) ![]BucketFile {
	mut args := args_

	self.check_installed()!
	code0 := self.pycode_init()!
	mut code := '
	bucket = b2_api.get_bucket_by_name("${args.bucketname}")
	res = []
	for file_version, folder_name in bucket.ls(latest_only=True, recursive=True):
		res.append({"file_name": file_version.file_name, "upload_timestamp": file_version.upload_timestamp})
	console.print_debug("==RESULT==")
	console.print_debug(json.dumps(list(res), indent=4))	
	'
	code = code0 + '\n' + texttools.dedent(code)

	res := self.py.exec(cmd: code)!
	console.print_debug(res)
	r := json.decode([]BucketFile, res)!
	console.print_debug(r.str())
	return r
}

// TODO: download/upload of full dir (sync)
pub struct SyncArgs {
	source string // local dir /home/afouda/Documents/testdir
	dest   string // bucket url b2://testdir
}

pub fn (mut self B2Client[Config]) sync(args_ SyncArgs) ! {
	mut args := args_

	self.check_installed()!
	code0 := self.pycode_init()!
	mut code := '
	source = parse_folder("${args.source}", b2_api)
	dest = parse_folder("${args.dest}", b2_api)
	policies_manager = ScanPoliciesManager(exclude_all_symlinks=True)
	import sys
	import time
	synchronizer = Synchronizer(
        max_workers=10,
		policies_manager=policies_manager,
        dry_run=False,
        allow_empty_source=True,
		  keep_days_or_delete=KeepOrDeleteMode.DELETE,
    )
	with SyncReport(sys.stdout, False) as reporter:
        synchronizer.sync_folders(
            source_folder=source,
            dest_folder=dest,
            now_millis=int(round(time.time() * 1000)),
            reporter=reporter,
        )
	
	'
	code = code0 + '\n' + texttools.dedent(code)

	res := self.py.exec(cmd: code, stdout: true)!
	console.print_debug(res)
}
