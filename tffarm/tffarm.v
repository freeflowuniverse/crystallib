module tffarm

pub struct TFFarm {
pub mut:
	name string
	//describe your farm
	description string
	network_ranges []NetworkRange
	nodes []Node
	location_type LocationType
	//give more information about location
	location_description string
	farming_wallet string
	//can be separate of farming wallet if needed, if not filled in then farming wallet used
	cultivation_wallet string
	//which public key do we need? Do we need it?
	pubkey string
}

pub enum LocationType {
	home
	office
	datacenter_commercial
	datacenter_private
	school
	//e.g. in building some remote room somewhere
	utility_room
	telco_tower
	solar_park
	other
}



//check there are no doubles and ranges are well constructed
pub fn (mut farm TFFarm) check() ? {

	mut name_check := []string

	for range in farm.ranges{
		range.check()?
		if range.name in name_check{
			return error("cannot have duplicate name")
		}
		name_check << range.name
	}

	for node in farm.nodes{
		node.check(farm)?
	}

	//TODO: check format wallets

}

//save as json's in defined path
//if not private then will save as relevant for github or other
//if private then also add mgmt info for e.g. IPMI
pub fn (mut farm TFFarm) save(path string, private bool) ? {
	farm.check()?
	//TODO: create path if it does not exist yet
	//TODO: for each node save a node_$name.json in the dir
	//TODO: for farm save as farm_$name.json
}
