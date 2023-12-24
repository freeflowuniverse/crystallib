module visualstudiocode
import freeflowuniverse.crystallib.osal
import os

@[params]
pub struct OpenArgs {
pub mut:
	path string
}

//if not specified will use current dir
pub fn open(args_ OpenArgs)!{
	mut args:=args_
	if args.path==""{
		args.path= os.getwd()
	}	
	check()!
	if ! os.exists(args.path){
		return error("Cannot open Visual Studio Code: could not find path $args.path")
	}
	cmd3 := "open -a \"Visual Studio Code\" ${args.path}"
	osal.execute_interactive(cmd3)!
}

//check visual studio code is installed
pub fn exists() bool{
	cmd:='ls /Applications | grep "Visual Studio Code'
	res:=os.execute(cmd)
	if res.exit_code>0{
		// return error("could not check visual studio code installed.\n$res")
		return false
	}
	return true
}

pub fn check()!{
	if exists()==false{
		return error("Visual studio code is not installed.\nPlease see https://code.visualstudio.com/download")
	}
}

//install visual studio code as 'code' cmd in os
pub fn cmd_install()!{
	check()!
	source:='/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code'
	osal.cmd_add(cmdname:'code',source:source,symlink:true,reset:true)!
}

@[params]
pub struct ExtensionsInstallArgs {
pub mut:
	extensions string
	default bool = true
}

pub fn extensions_install(args_ ExtensionsInstallArgs)!{
	mut args:=args_
	mut items:=[]string{}
	for item in args.extensions.split(",").map(it.trim_space()){
		if ! (item in items){
			items<<item
		}
	}
	default:=[
		"golang.go",
		"ms-azuretools.vscode-docker",
		"ms-python.autopep8",
		"ms-python.python",
		"ms-vscode-remote.remote-ssh",
		"ms-vscode-remote.remote-ssh-edit",
		"ms-vscode-remote.remote-containers",
		"ms-vscode.cmake-tools",
		"ms-vscode.makefile-tools",
		"ms-vscode.remote-explorer",
		"ms-vscode.remote-repositories",
		"ms-vsliveshare.vsliveshare",
		"redhat.vscode-yaml",
		"rust-lang.rust-analyzer",
		"sumneko.lua",
		"shd101wyy.markdown-preview-enhanced",
		"TakumiI.markdowntable",
		"telesoho.vscode-markdown-paste-image",
		"tamasfe.even-better-toml",
		"tomoki1207.pdf",
		"VOSCA.vscode-v-analyzer",
		"yzhang.markdown-all-in-one",
		"zamerick.vscode-caddyfile-syntax",
		"zxh404.vscode-proto3"
	]
	if args.default{
		for item in default{
			if ! (item in items){
				items<<item
			}			
		}
	}
	for item in items{
		cmd:='code --install-extension ${item}'
		res:=os.execute(cmd)
		if res.exit_code>0{
			return error("could not install visual studio code extension:'${item}'.\n$res")
		}			
	}
}


pub fn extensions_list()![]string{
	cmd:='code  --list-extensions'
	res:=os.execute(cmd)
	if res.exit_code>0{
		return error("could not list visual studio code extensions.\n$res")
	}	
	mut res2:=[]string{}
	for i in res.output.split_into_lines().map(it.trim_space()){
		if i==""{
			continue
		}
		res2<<i
	}
	return res2
}