module circles

import time

pub struct Circle {
pub:
	milestones map[string]&Milestone @[root_object: 'Milestone']
	stories    map[string]&Story     @[root_object: 'Story']
}
