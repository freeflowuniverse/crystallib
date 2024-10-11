module meet

pub struct Meet {}

pub fn (meet Meet) html() string {
	dollar := '$'
	return $tmpl('./templates/meet.html')
}

pub struct Room {}

pub fn (room Room) html() string {
	dollar := '$'
	return $tmpl('./templates/room.html')
}

// pub struct LiveKitRoom {
//     pub mut:
//         server_url           string
//         token                string
//         audio                bool
//         video                bool
//         screen               bool
//         connect              bool = true
//         options              RoomOptions
//         connect_options      RoomConnectOptions
//         simulate_participants int
//         feature_flags        map[string]bool
//         // room                 Room
// }
