module regext

import os

fn test_stdtext() {
	// this is test without much fancyness, just rext replace, no regex, all case sensitive

	text := '

!!action.something sid:aa733

sid:aa733

...sid:aa733 ss

...sid:rrrrrr ss
sid:997

   sid:s d
sid:s_d

'

	r := find_sid(text)

	assert r == ['aa733', 'aa733', 'aa733', '997']
}
