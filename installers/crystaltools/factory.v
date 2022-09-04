module crystaltools
import builder

enum State{
	ok
	error
	reset
}
struct Installer{
	node &builder.Node
	state State
}

//install crystaltools will return true if it was already installed
pub fn get(mut node builder.Node)?Installer{
	mut i:=Installer{node:&node}
	return i
}
