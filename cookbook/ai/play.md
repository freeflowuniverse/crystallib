
EXAMPLE HEROSCRIPT:

```heroscript

//example script
const dagu_script = "
!!dagu.configure
	instance: 'test'
	username: 'admin'
	password: 'testpassword'

!!dagu.new_dag
	name: 'test_dag'

!!dagu.add_step
	dag: 'test_dag'
	name: 'hello_world'
	command: 'echo hello world'

!!dagu.add_step
	dag: 'test_dag'
	name: 'last_step'
	command: 'echo last step'


```

fn test_play_dagu() ! {
	mut plbook := playbook.new(text: thetext_from_above)!
	play_dagu(mut plbook)! //see below in vlang block there it all happens
}


## THE CODE WHICH CONVERTS ABOVE TO THE STRUCTS IN VLANG


```vlang


pub fn play_dagu(mut plbook playbook.PlayBook) ! {

    //find all actions are !!$actionname.  in this case above is !!dagu.
	dagu_actions := plbook.find(filter: 'dagu.')!
	if dagu_actions.len == 0 {
		return
	}
	

	play_dagu_basic(mut plbook)!
}


// play_dagu plays the dagu play commands
pub fn play_dagu_basic(mut plbook playbook.PlayBook) ! {

	//now find the specific ones for dagu.install
	mut install_actions := plbook.find(filter: 'dagu.install')!

	if install_actions.len > 0 {
		for install_action in install_actions {
            //INFO: see params.md for the available actions on the params
			mut p := install_action.params
            //INFO: in params.md you can see that get_default exists and how the value homedir can be found
			homedir := p.get_default('homedir', '${os.home_dir()}/hero/var/dagu')!
			configpath := p.get_default('configpath', '${os.home_dir()}/hero/cfg/dagu.yaml')!
			username := p.get_default('username', '')!
			password := p.get_default('password', '')!
			secret := p.get_default('secret', '')!
			title := p.get_default('title', 'My Hero DAG')!
			reset := p.get_default_false('reset')
			start := p.get_default_true('start')
			stop := p.get_default_false('stop')
			restart := p.get_default_false('restart')
			ipaddr := p.get_default('ipaddr', '')!
			port := p.get_int_default('port', 8888)!

            //in this case we call an installer but this could have been  a struct which needed to be filled in
			daguinstaller.install(
				homedir: homedir
				configpath: configpath
				username: username
				password: password
				secret: secret
				title: title
				reset: reset
				start: start
				stop:stop
				restart: restart
				host: ipaddr
				port: port
			)!
		}
	}

    //ofcourse there can be more further
	
}

```