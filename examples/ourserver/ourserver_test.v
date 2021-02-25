module ourserver



fn test_aa(){

	go server_start()

	tcp_port_test("127.0.0.1",tcp_server_port,5) or {panic("could not connect to server")}

	for i in 0..100{
		go sender(i)
	}

	panic("a")
}