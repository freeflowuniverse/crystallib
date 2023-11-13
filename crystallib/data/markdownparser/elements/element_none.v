module elements

pub struct None {
	DocBase
}

pub fn (mut self None) process() !int {
	return 0
}

pub fn (mut self None) markdown() string {
	return 'none'
}

pub fn (mut self None) html() string {
	return self.markdown()
}

pub fn none_new(args_ TableNewArgs) None {
	return None{}
}
