import despiegk.crystallib.hostsfile

pub fn main() {
	mut hostsfile := hostsfile.load()
	println(hostsfile)
	hostsfile.reset(['pubtools'])
	println(hostsfile)
	hostsfile.add('127.0.0.1', 'www5.test.local', 'pubtools')
	println(hostsfile)
	hostsfile.delete('www5.test.local')
	println(hostsfile)
	hostsfile.add('127.0.0.1', 'www20.test.local', 'pubtools')
	println(hostsfile)
	hostsfile.save()
}
