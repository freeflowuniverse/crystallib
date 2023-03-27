module params

import time {Time}

const testparams = Params{
	params: [
		Param{
			key: 'when'
			value: '2022-12-5 20:14:35'
		},
		Param{
			key: 'date'
			value: '2022-12-5'
		},
		Param{
			key: 'interval'
			value: '2022-12-5'
		}
	]	
}

fn test_get_time() ! {
	sometime := testparams.get_time('when')!
	assert sometime.unix == 1670260475

	anothertime := testparams.get_time('date')!
	assert anothertime.unix == 1670187600
}


fn test_get_time_default() ! {
	notime := testparams.get_time_default('now', time.now())!
	assert notime.day == time.now().day
}

fn test_get_time_interval() ! {
	//
}