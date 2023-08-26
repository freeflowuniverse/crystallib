module osal
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools

[params]
pub struct DownloadArgs {
pub mut:
	name       string //unique name which will be used in the cache
	url        string
	reset      bool   //will remove
	minsize_kb u32 = 10 //is always in kb
	maxsize_kb u32
	hash       string // if hash is known, will verify what hash is
	dest	   string // if specified will copy to that destination	
	timeout	int = 180
	retry int = 3
}

//if name is not specified, then will be the filename part
pub fn download(args_ DownloadArgs) !pathlib.Path{
	mut args:=args_

	if args.name==""{
		args.name=args.url.split("/").last()
		if args.name.contains("?"){
			return error("cannot get name from url if ? in the last part after /")
		}
		args.name=texttools.name_fix(args.name)		
	}

	if args.dest.contains("@name"){
		args.dest=args.dest.replace("@name",args.name)
	}
	if args.url.contains("@name"){
		args.url=args.url.replace("@name",args.name)
	}

	if args.dest==""{
		args.dest = "/tmp/${args.name}"
	}

	if ! cmd_exists('curl'){
		return error("please make sure curl has been installed.")
	} 

	mut dest:=pathlib.get_file(args.dest,false)!

	//now check to see the url is not different
	mut meta:=pathlib.get_file(args.dest+".meta",true)!
	metadata:=meta.read()!
	if metadata.trim_space() != args.url.trim_space(){
		//means is a new one need to delete
		args.reset=true
		dest.delete()!
	}	
	if args.reset{
		mut dest_delete:=pathlib.get_file(args.dest+"_",false)!
		dest_delete.delete()!
	}
	meta.write(args.url.trim_space())!

	//check if the file exists, if yes and right size lets return
	if dest.exists() {
		size:=dest.size_kb()!
		if args.minsize_kb>0{
			if size > args.minsize_kb{
				if args.maxsize_kb>0{
					if  size < args.maxsize_kb{return dest}
				}else{
					return dest
				}
			}
		}
	}

	mut dest0:=pathlib.get_file(args.dest+"_",false)!

	cmd:='
		rm -f ${dest0.path}_
		cd /tmp
		curl -L ${args.url} -o ${dest0.path}
		'
	exec(cmd:cmd,timeout:args.timeout, retry:args.retry,debug:false
			description:"download ${args.url} to ${dest0.path}")!


	if dest0.exists() {
		size0:=dest0.size_kb()!
		println(size0)
		if args.minsize_kb>0{
			if size0 < args.minsize_kb{
				return error("Could not download ${args.url} to ${dest0.path}, size (${size0}) was smaller than ${args.minsize_kb}")
			}
		}
		if args.maxsize_kb>0{
			if size0 > args.maxsize_kb{
				return error ("Could not download ${args.url} to ${dest0.path}, size (${size0}) was larger than ${args.maxsize_kb}")
			}
		}		
	}

	// dest1:=dest0.copy(mut dest)!
	// dest0.delete()!
	return dest0

}
