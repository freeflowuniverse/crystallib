module installer

import os
import freeflowuniverse.crystallib.core.pathlib
import json

import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.ui.console

@[params]
pub struct GeneratorArgs {
pub mut:
	name string
	title string
	build_deps Deps
	install_deps Deps
	supported_platforms SupportedPlatforms
	reset bool //regenerate all, dangerous !!!
	interactive bool = true
}

pub struct Deps{
pub mut:
	golang bool 
	python bool
	nodejs bool
	rust bool
}

pub struct SupportedPlatforms{
pub mut:
	ubuntu bool = true
	osx bool
	windows bool
}


pub struct TemplateItem{
pub mut:
	dest string //directory where the template needs to go too
	name string //name which can be used for variable
	path string //where template is in the template dir
}



pub fn generate(args_  GeneratorArgs)!{

	mut args:=args_

	codedir := os.getwd()
	config_path:="${codedir}/generate_config.json"

	if os.exists(config_path) && args.reset{
		os.rm(config_path)!	
	}

	if os.exists(config_path){
		mut p_config:=pathlib.get_file(path:config_path)!
		config:=p_config.read()!
		args=json.decode(GeneratorArgs,config)!
	}else{

		if args.interactive{			
			//now ask the questions if interactive
			mut myui:=ui.new()!
			console.clear()
			ok:=myui.ask_yesno(question:"are you sure you want to generate in dir:'${codedir}'?")!
			if !ok{
				return error("can't continue, user aborted.")
			}
			args.name=myui.ask_question(question:"what is the name of your module?")!
			args.title=myui.ask_question(question:"what is the tile of your installer, if empy same as name?",default:args.name)!
			build_deps:=myui.ask_dropdown_multiple(question:"Which build deps do you want?",items:["go","python","nodejs","rust"])!
			install_deps:=myui.ask_dropdown_multiple(question:"Which install deps do you want?",items:["go","python","nodejs","rust"])!
			supported_platforms:=myui.ask_dropdown_multiple(question:"Which platforms do you support?",items:["ubuntu","osx"])!

			deps_process(mut args.build_deps,build_deps)
			deps_process(mut args.install_deps,install_deps)
			supported_platforms_process(mut args.supported_platforms,supported_platforms)



		}
		
		mut p_config:=pathlib.get_file(path:config_path,create:true)!
		data:=json.encode(args)
		p_config.write(data)!
	}

	mut template_items:=[]TemplateItem{}

	checkplatform:=args.supported_platforms.check_str()

	c_b := $tmpl("templates/builder.v")
	c_i := $tmpl("templates/installer.v")
	c_r := $tmpl("templates/readme.md")
	c_s := $tmpl("templates/server.v")



}

fn deps_process(mut e Deps, deps []string) {
	for item in deps{
		match item {
			"go"{
				e.golang  = true }
			"python"{
				e.python  = true }
			"nodejs"{
				e.nodejs  = true }				
			"rust"{
				e.rust  = true		
			}else{
				panic("bug in deps process")
			}
		}
	}
}

fn supported_platforms_process(mut e SupportedPlatforms, supported_platforms []string) {
	for item in supported_platforms{
		match item {
			"osx"{
				e.osx  = true 
				}
			"ubuntu"{
				e.ubuntu  = true 
			}else{
				panic("bug in deps process")
			}
		}
	}
}



pub fn (o SupportedPlatforms) list_str()string{

	mut out:=[]string{}

	if o.osx{
		out<<".osx"
	}
	if o.ubuntu{
		out<<".ubuntu"
	}

	return out.join(",")

}

pub fn (o SupportedPlatforms) check_str() string{

	mut out:=""

	if o.osx{
		out+="myplatform == .osx || "
	}
	if o.ubuntu{
		out+="myplatform == .ubuntu ||"
	}

	out=out.trim_right("|")

	return out

}