module params

import time

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
		},
	]
}

fn test_get_time() ! {
	sometime := params.testparams.get_time('when')!
	assert sometime.unix == 1670260475

	anothertime := params.testparams.get_time('date')!
	assert anothertime.unix == 1670187600
}

fn test_get_time_default() ! {
	notime := params.testparams.get_time_default('now', time.now())!
	assert notime.day == time.now().day
}

fn test_get_time_interval() ! {
	//
}
