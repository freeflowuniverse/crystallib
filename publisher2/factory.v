module publisher2


// install mdbook will return true if it was already installed
pub fn get(mut node builder.Node) ?Installer {
	mut i := Installer{
		node: &node
	}
	return i
}