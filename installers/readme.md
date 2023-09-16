# Installers

This is a set of installers, they are all using the builder functionality.

> TODO: need to finish & create examples

## A simple example using brew

see imagemagick

```golang
import os

import installers.base
import process

//this gets the name of the directory
const installername = os.base(os.dir(@FILE))

// install imagemagick will return true if it was already installed
pub fn  install() ! {

	println(' - $node.name: install $installername')
	if !osal.done_exists('install_${installername}') {
		if osal.platform() == builder.PlatformType.ubuntu{
			package_install(name:"imagemagick")!
		} else {
			panic('only ubuntu and osx supported for now')
		}
	osal.done_set('install_${installername}', 'OK')!
	println(' - ${installername} already done')
}

```

typically the factory is always the same, in this case we did the trick with installername to reuse even more
