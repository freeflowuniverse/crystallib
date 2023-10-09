module console

pub struct UIConsole {
pub mut:
	x_max int = 80
	y_max int = 60
}

pub fn new() UIConsole {
	return UIConsole{}
}
