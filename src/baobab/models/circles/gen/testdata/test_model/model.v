module circles

import time

pub struct Circle {
pub:
	epics   map[string]&Epic   [root_object: 'Epic']
	stories map[string]&Story  [root_object: 'Story']
	sprints map[string]&Sprint [root_object: 'Sprint']
}
