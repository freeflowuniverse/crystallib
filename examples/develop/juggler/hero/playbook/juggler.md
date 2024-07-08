!!juggler.configure
	url: 'https://git.ourworld.tf/projectmycelium/itenv'
    username: 'admin'
    password: 'planetpeoplefirst'
    port: 8000

!!caddy.add_reverse_proxy
    from: ':8000'
    to: juggler.protocol.me