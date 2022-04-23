module publisher_config



// the main config file for a publishing environment
// name of the json needs to be config.json
// EXAMPLE JSON:
// {
//     "reset": false,
//     "pull": false,
//     "debug": false,
//     "redis": false,
//     "port": 9998,
//     "paths": {
//         "base": "",
//         "code": "",
//         "codewiki": "",
//         "publish": ""
//     }
// }
pub struct PublishConfig {
pub mut:
	reset bool
	pull  bool
	debug bool
	redis bool
	port  int = 9998
	paths Paths
	multibranch bool
	// publish_servers []string

}
