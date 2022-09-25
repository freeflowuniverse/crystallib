module twinclientinterfaces


pub fn new_twin_client(transport ITwinTransport) ?TwinClient {
	return TwinClient{
		transport: transport
	}
}
