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
// download
[params]
pub struct DownloadArgs{
pub mut:
	file_name string
	dest string
	bucketname string
}

pub fn (mut self B2Client[Config]) download(args_ DownloadArgs) !{
	mut args:=args_
	mut cfg:=self.config()!
	
	if !os.exists(os.dir(args.dest)){
		return error("cannot download ${args.file_name} to local file system: ${os.dir(args.dest)} doesn't exist")
	}
	if args.bucketname==""{
		args.bucketname=cfg.bucketname
	}
	self.check_installed()!
	code0:=self.pycode_init()!
	mut code:='
	bucket = b2_api.get_bucket_by_name("${args.bucketname}")
	downloaded_file = bucket.download_file_by_name("${args.file_name}")
	downloaded_file.save_to("${args.dest}")
	'
	code=code0+"\n"+texttools.dedent(code)

	console.print_debug("download b2:${self.instance}\n$args")
	self.py.exec(cmd:code,stdout:true)!

}
// bucket type enum
pub enum BucketType {
    allpublic
    allprivate
    
}

// Implement the to_string method for the Fruit enum
pub fn (bt BucketType) to_string() string {
    match bt {
		.allpublic { return('allPublic')}
		.allprivate { return ('allPrivate')}
    }
}


// create Bucket
[params]
pub struct CreateBucketArgs{
pub mut:
	bucketname string
	buckettype BucketType
}

pub fn (mut self B2Client[Config]) create_bucket(args_ CreateBucketArgs) !{
	mut args:=args_
	mut cfg:=self.config()!
if args.bucketname==""{
		args.bucketname=cfg.bucketname
	}
	self.check_installed()!
	code0:=self.pycode_init()!
	mut code:='
	b2_api.create_bucket("${args.bucketname}", "${args.buckettype.to_string()}")
	'
	code=code0+"\n"+texttools.dedent(code)

	console.print_debug("create Bucket b2:${self.instance}\n$args")
	self.py.exec(cmd:code,stdout:true)!

}
// Delete Bucket
[params]
pub struct DeleteBucketArgs{
pub mut:
	bucketname string
}

pub fn (mut self B2Client[Config]) delete_bucket(args_ DeleteBucketArgs) !{
	mut args:=args_
	mut cfg:=self.config()!
if args.bucketname==""{
		args.bucketname=cfg.bucketname
	}
	self.check_installed()!
	code0:=self.pycode_init()!
	mut code:='
	bucket = b2_api.get_bucket_by_name("${args.bucketname}")
	b2_api.delete_bucket(bucket)
	'
	code=code0+"\n"+texttools.dedent(code)

	console.print_debug("delete Bucket b2:${self.instance}\n$args")
	self.py.exec(cmd:code,stdout:true)!

}
//TODO: download/upload of full dir (sync)
//TODO: see how we can show progress when stdout chosen

