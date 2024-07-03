module caddy

import rand

pub fn authorization_policy(policy_ AuthorizationPolicy) AuthorizationPolicy {
	mut policy := policy_
	// if policy.crypto_key_verify == '' {
	// 	policy.crypto_key_verify = rand.uuid_v4()
	// }
	return policy
}
