module usermanager

// Data object for user
pub struct User {
pub mut:
	name               string
	description        string
	remarks            string
	timestamp_creation time.Time
	timestamp_modified time.Time
	guid               string
	contacts           []Contact // list of contacts for a user
}
