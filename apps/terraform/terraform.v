module terraform

pub enum State {
	init
	ok
	old
}


[heap]
pub struct Terraform {
pub mut:
	// lastscan	time.Time
	state		State
}


//needed to get singleton
fn init_singleton() &Terraform {
	mut f := terraform.Terraform{}	
	return &f
}

//singleton creation
const terraformobj = init_singleton()


pub fn get() ?&Terraform {
	mut obj := terraform.terraformobj
	return obj
}



pub fn (mut app Terraform) check()? {


}
