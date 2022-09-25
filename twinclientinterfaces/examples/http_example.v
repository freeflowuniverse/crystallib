import crystallib.twinclientinterfaces as tw


fn main() {
	mut transport := tw.HttpTwinClient{}
	transport.init()?
	mut twin := tw.new_twin_client(transport)?
	println(twin.algorand_list()?)
}
