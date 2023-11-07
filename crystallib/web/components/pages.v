module components

pub struct Shell {
pub:
	navbar Navbar
	// content IComponent
	// sidebar ISidebar
	// footer  IFooter
}

pub fn (page Shell) html() string {
	return $tmpl('./templates/shell.html')
}

// pub struct HomePage {
// 	hero Hero
// }

// pub fn (page HomePage) html() string {
// 	return $tmpl('./templates/home.html')
// }
