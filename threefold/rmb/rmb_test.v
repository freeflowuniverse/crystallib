module rmb


fn test_main() ? {

	mut cl:=new(nettype:.dev)!
	
	mut r:=cl.get_zos_statistics(1)!

	println(r)

	panic("ddd")

}