module tfgrid

import freeflowuniverse.crystallib.core.actionsparser { Action }

fn (mut t TFGridHandler) core(action Action) ! {
	match action.name {
		'login' {
			mnemonic := action.params.get_default('mnemonic', '')!
			netstring := action.params.get_default('network', 'main')!

			t.tfgrid.load(mnemonic: mnemonic, network: netstring)!
		}
		else {
			return error('core action ${action.name} is invalid')
		}
	}
}
