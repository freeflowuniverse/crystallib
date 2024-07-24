!!juggler.configure
	url: 'https://git.ourworld.tf/projectmycelium/itenv'
    username: ''
    password: ''
    port: 8000

!!juggler.start

!!caddy.add_reverse_proxy
    from: ':8000'
    to: juggler.protocol.me

!!caddy.generate
!!caddy.start