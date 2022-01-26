module ffeditor

import builder
import sshagent

enum FFEditorState{
	init
	ok
	error
}

[heap]
pub struct FFEditor {
pub mut:
	vscode_extensions_dir		string	
	github_username				string
	state 						FFEditorState
}


//needed to get singleton
fn init_singleton() &FFEditor {
	mut f := ffeditor.FFEditor{}	
	return &f
}


//singleton creation
const factory = init_singleton()

fn vscode_install(){
	cmd:="cd /tmp && curl -L 'https://code.visualstudio.com/sha/download?build=stable&os=darwin-arm64' -o vscode.zip"

}

fn vscode_uninstall(){
	"$HOME/Library/Application Support/Code"
	"~/.vscode"

	//$HOME/.config/Code and ~/.vscode.
}

fn get() &FFEditor {
	f := ffeditor.factory
	if f.state == .init{
		sshagent
	}
}

