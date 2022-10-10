module pathlib

// import os

struct PathList {
	// is the root under which all paths are, think about it like a changeroot environment
	root  string
	paths []Path
mut:
	exists i8
}

// copy all
// pub fn (mut pathlist PathList) copy(dest Path)?Path{
// }

// //delete all
// pub fn (mut pathlist PathList) delete(dest Path)?Path{
// }

// //return relative path of path in relation to root in PathList
// pub fn (mut pathlist PathList) path_relative()?_get(path Path)?string{
// }

// pub fn (mut pathlist PathList) path_abs_get(path Path)?string{
// }

// pub fn (mut pathlist PathList) add(path Path){
// }
