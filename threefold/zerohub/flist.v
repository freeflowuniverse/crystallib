module tfgrid



pub struct TFGridClient {
pub mut:
	redis &redisclient.Redis [str: skip]
}


//structure which represents flist
pub struct Flist{
pub:	
	flisturl string //full path to downloadable flist
}





pub fn (mut cl TFGridClient) flists_get()! []Flist {
	return []Flist{}
}