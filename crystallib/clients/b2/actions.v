module b2

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.ui.console
import json
import os
// res:=py.exec(cmd:cmd)!

fn (mut self B2Client[Config]) pycode_init() !string {
	mut cfg := self.config()!
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
		if !self.py.pips_done_check(item) {
			self.py.pip(item)!
		}
	}
}

pub struct BucketItem {
pub:
	id    string
	type_ string
	name  string
}

pub fn (mut self B2Client[Config]) list_buckets() ![]BucketItem {
	self.check_installed()!
	code0 := self.pycode_init()!
	mut code := '
	res=b2_api.list_buckets()
	res2=[]
	for x in res:
    	res2.append({"id":x.id_,"type_":x.type_,"name":x.name})
	print("==RESULT==")
	print(json.dumps(list(res2), indent=4))	
	'
	code = code0 + '\n' + texttools.dedent(code)

	res := self.py.exec(cmd: code)!
	r := json.decode([]BucketItem, res)!
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
	mut cfg := self.config()!

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

// TODO: download
// TODO: download/upload of full dir (sync)
// TODO: see how we can show progress when stdout chosen
// TODO: create/delete bucket
