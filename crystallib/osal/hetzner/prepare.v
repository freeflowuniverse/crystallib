
module hetzner

//TODO: couldn't get ssh lib to work

// pub fn (h HetznerClient) server_prepare(name string) !bool {
// 	srvs := h.servers_list()!

// 	// println(srvs)
// 	mut srvid := 0
// 	mut srvip := ""

// 	for s in srvs {
// 		if s.server.server_name == name {
// 			// print(s)
// 			srvid = s.server.server_number
// 			srvip = s.server.server_ip
// 		}
// 	}

// 	if srvid == 0 {
// 		panic("could not find server")
// 	}

// 	println("[+] request rescue mode")
// 	resc := h.server_rescue(srvid)!
// 	password := resc.rescue.password
// 	println("[+] rescue password: $password")
// 	// println(resc)

// 	println("[+] fetching server information")
// 	boot := h.server_boot(srvid)!
// 	// println(boot)

// 	println("[+] forcing reboot")
// 	reset := h.server_reset(srvid)!
// 	// println(reset)

// 	time.sleep(30000 * time.millisecond)

// 	println("[+] waiting for rescue to be ready")
// 	for {
// 		target := vssh.new(srvip, 22) or {
// 			println("$err")
// 			time.sleep(30000 * time.millisecond)
// 			continue
// 		}

// 		// rescue doesn't support keyboard-interactive, fallback to password
// 		target.authenticate(.password, "root", password)!
// 		check := target.execute("grep 'Hetzner Rescue System.' /etc/motd")!
// 		if check.exitcode == 0 {
// 			println("[+] we are logged in on the rescue system !")

// 			// executing deployment binary
// 			target.upload(os.args[0], "/tmp/deployment")!
// 			target.stream("stdbuf -i0 -o0 -e0 /tmp/deployment")!

// 			exit(0)
// 		}
// 	}

// 	return true
// }
