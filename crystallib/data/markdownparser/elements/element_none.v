module elements

pub struct None {
	DocBase
}

fn (mut self None) process(mut elements []DocElement) !int {
	return 0	
}

fn (mut self None) markdown() string {
	return "none"
}

fn (mut self None) html() string {
	return self.markdown()
}
