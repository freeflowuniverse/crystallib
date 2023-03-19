module zerohub

const secret="6Pz6giOpHSaA3KdYI6LLpGSLmDmzmRkVdwvc7S-E5PVB0-iRfgDKW9Rb_ZTlj-xEW4_uSCa5VsyoRsML7DunA1sia3Jpc3RvZi4zYm90IiwgMTY3OTIxNTc3MF0="

fn test_main() ? {

	mut cl:=new(secret:secret)!

	mut flists := fl.flists_get()!

	println(flists)

	panic("ddd")

}