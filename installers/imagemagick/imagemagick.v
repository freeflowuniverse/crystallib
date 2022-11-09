module imagemagick

import os
import freeflowuniverse.crystallib.builder
import installers.base
import process

// this gets the name of the directory
const installername = os.base(os.dir(@FILE))

// install imagemagick will return true if it was already installed
pub fn (mut i Installer) install() ! {
	mut node := i.node
	println(' - $node.name: install $imagemagick.installername')
	if !node.done_exists('install_$imagemagick.installername') {
		if node.platform == builder.PlatformType.osx || node.platform == builder.PlatformType.ubuntu {
			node.package_install(name: 'imagemagick')!
		} else {
			panic('only ubuntu and osx supported for now')
		}
		node.done_set('install_$imagemagick.installername', 'OK')!
	}
	println(' - $imagemagick.installername already done')
}

// pub fn (mut i Installer) update() ! {
// 	mut node := i.node
// 	panic("to implement")
// 	node.done_set('update_crystaltools', 'OK')!
// }
