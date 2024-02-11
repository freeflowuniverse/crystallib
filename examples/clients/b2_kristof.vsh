#!/usr/bin/env -S v -w -enable-globals run
import freeflowuniverse.crystallib.clients.b2

mut cl:=b2.get(instance:"despiegktest")!

mut cfg := cl.config()!
// TO CONFIGURE NEW 
// cl.config_delete()!

cfg.keyid='cd8f15212206'
cfg.appkey='005ce2a07db78e278c3fd62079fc6293e7fd0ec41e'
cfg.bucketname='despiegktest'
cl.config_save()!

if cfg.appkey==""{
	cl.config_interactive()!
}

println(cfg)


items:=cl.list_buckets()!
println(items)


cl.upload(src:"/Users/despiegk1/Downloads/OurWorld Venture Creator Investor Intro - Jan 2024 v7.2.pdf")!