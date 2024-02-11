#!/usr/bin/env -S v -w -enable-globals run
import freeflowuniverse.crystallib.clients.b2

mut cl:=b2.get(instance:"despiegktest")!

mut cfg := cl.config()!
// TO CONFIGURE NEW 
// cl.config_delete()!

cfg.keyid='cd8f15212206'
cfg.appkey=''
cfg.bucketname='despiegktest'
cl.config_save()!

if cfg.appkey==""{
	cl.config_interactive()!
}

println(cfg)


println(cl.list_buckets()!)


cl.download(file_name: "hero", dest: '/tmp/hero')!
cl.create_bucket(bucketname: "testashraf", buckettype: b2.BucketType.allprivate)!
println(cl.list_buckets()!)
cl.delete_bucket(bucketname: "testashraf")!
println(cl.list_buckets()!)
