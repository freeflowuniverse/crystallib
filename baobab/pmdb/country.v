module pmdb
import freeflowuniverse.protocolme.models.people



// Function to get a country
// ARGS:
// country string - can be name or code
pub fn (mut memdb MemDB) country_get (country string) !&people.Country {
	country_ := texttools.name_fix_no_underscore_no_ext(country).to_lower()
	for _, value in data.countries {
		if (value.name.to_lower() == country_)||(value.code2.to_lower() == country_)||(value.code3.to_lower() == country_) {
			return value
		} 
	}
	return error("Failed to find country: $country")
}