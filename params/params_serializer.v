

module params
import freeflowuniverse.crystallib.resp

pub fn (mut p Params) str()string {
	//TODO: walk over params fill in a serialized string
	//TODO: Jonathan, do a test we can go from one to other & back, so can be used as serialization
	return ""
}

//encode using resp (redis procotol)
pub fn (mut p Params) to_resp() ![]u8 {
	//find a way how we can generic serialize & deserlize from and to resp
	//TODO: Jonathan, do a test we can go from one to other & back, so can be used as serialization
	return []u8
}

pub fn (mut p Params) from_resp(data []u8) !{
	//find a way how we can generic serialize & deserlize from and to resp
	//TODO: Jonathan, do a test we can go from one to other & back, so can be used as serialization
}
