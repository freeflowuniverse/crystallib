module components

pub struct Navbar {
pub:
	menu Menu
}

pub struct Menu {
pub:
	logo  string
	items []MenuItem
}

pub struct MenuItem {
pub:
	label string
	route string
}

pub fn (navbar Navbar) html() string {
	return $tmpl('./templates/navbar.html')
}
