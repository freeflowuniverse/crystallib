#!/usr/bin/env v

fn sh(cmd string) {
	println('❯ ${cmd}')
	print(execute_or_exit(cmd).output)
}

vroot := @VROOT
abs_dir_of_script := dir(@FILE)

sh('
set -ex
cd ~/code/github/freeflowuniverse/crystallib

# link crystallib to .vmodules
mkdir -p ~/.vmodules/freeflowuniverse
unlink ~/.vmodules/freeflowuniverse/crystallib
ln -s ${abs_dir_of_script}/crystallib ~/.vmodules/freeflowuniverse/crystallib

# link necessary testing module to .vmodules/vlang
mkdir -p ~/.vmodules/vlang
if [ -L ~/.vmodules/vlang/testing ] ; then
	unlink ~/.vmodules/vlang/testing
fi
ln -s ${vroot}/cmd/tools/modules/testing ~/.vmodules/vlang/testing

# compile crystallib binary
v -enable-globals ${abs_dir_of_script}/cli/crystallib.v
rm -f /usr/local/bin/crystallib
ln -s ${abs_dir_of_script}/cli/crystallib /usr/local/bin/crystallib
# bash doc.sh
')
