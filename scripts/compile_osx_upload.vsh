#!/usr/bin/env -S v -n -w -enable-globals run
import freeflowuniverse.crystallib.clients.b2
import os

//make sure you have this pre-configured in your hero
mut cl:=b2.get("herobin")!

// keyid:'e2a7be6357fb'
// appkey:'...'
// bucketname:'threefold'

// items:=cl.list_buckets()!
// println(items)

println("build hero")
res:=os.execute("${os.home_dir()}/code/github/freeflowuniverse/crystallib/cli/hero/compile_debug.sh")
if res.exit_code > 0 {
	println('cannot build hero.\n${res}')
	exit(1)
}


//items:=["hero","mdbook","mdbook-echarts","mdbook-mermaid","mdbook-kroki-preprocessor","tailwind","v-analyzer","mdbook-kroki-preprocessor","mycelium"]
items:=["hero"]

println("upload components")
for name in items{
	src:="${os.home_dir()}/hero/bin/${name}"
	if os.exists(src){
		println("upload ${src}")
		cl.upload(src:src,dest:'macos-arm64/${name}')!
	}	
}

println("check hero installer")

res2:=os.execute("${os.home_dir()}/code/github/freeflowuniverse/crystallib/scripts/install_hero.sh")
if res2.exit_code > 0 {
	println('cannot install hero.\n${res}')
	exit(1)
}

res3:=os.execute("hero -version")
if res3.exit_code > 0 {
	println('cannot see version of hero.\n${res}')
	exit(1)
}
println(res3.output)
