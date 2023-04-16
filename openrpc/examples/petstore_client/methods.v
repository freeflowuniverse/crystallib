module petstore_client

// get_pets finds pets in the system that the user has access to by tags and within a limit
// - tags: tags to filter by
// - limit: maximum number of results to return
// returns pet_list, all pets from the system, that mathes the tags
pub fn (mut client Client) get_pets(tags []string, limit int) []Pet {}

[params]
struct NewPet {
	name string [required]
	tag string
}

// create_pet creates a new pet in the store. Duplicates are allowed.
// - new_pet: Pet to add to the store.
// returns pet, the newly created pet
pub fn (mut client Client) create_pet(new_pet NewPet) Pet {}

// get_pet_by_id gets a pet based on a single ID, if the user has access to the pet
// - id: ID of pet to fetch
// returns pet, pet response
pub fn (mut client Client) get_pet_by_id(id int) Pet {}

// delete_pet_by_id deletes a single pet based on the ID supplied
// - id: ID of pet to delete
// returns pet, pet deleted
pub fn (mut client Client) delete_pet_by_id(id int) {}