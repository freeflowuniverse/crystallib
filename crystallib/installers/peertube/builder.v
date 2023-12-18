module peertube

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.installers





@[params]
pub struct BuildArgs {
pub mut:
    reset bool
}

// install peertube will return true if it was already installed
pub fn build(args BuildArgs) ! {

    checkplatform()!
    
    base.install()!

	docker.install()!

    // install peertube if it was already done will return true
    println(' - build peertube')


	mut gs := gittools.get()!

	mut dest := gittools.code_get(
		url: 'https://github.com/Chocobozzz/PeerTube.git'
		pull: true
		reset: true
	)!

        


    // cmd := '
    // source ${osal.profile_path()} //source the go path
    // cd ${gitpath}


    // '
    // osal.execute_stdout(cmd)!


}
