module python



fn test_python() {

	py:=new() or {panic(err)}
	py.update() or {panic(err)}
	py.pip("ipython") or {panic(err)}


}

