module template

pub struct UIExample {
pub mut:
	x_max int = 80
	y_max int = 60
}

pub fn new() UIExample {
	return UIExample{}
}
