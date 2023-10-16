module tfgrid

import freeflowuniverse.crystallib.core.actionsparser { Action }
import threefoldtech.web3gw.tfgrid { GetStatistics }

pub fn (mut h TFGridHandler) stats(action Action) ! {
	match action.name {
		'get' {
			// network := action.params.get_default('network', 'main')!
			// h.explorer.load(network)!

			mut filter := GetStatistics{}
			if action.params.exists('status') {
				filter.status = action.params.get('status')!
			}

			res := h.tfgrid.statistics(filter)!
			h.logger.info('stats: ${res}')
		}
		else {
			return error('explorer does not support operation: ${action.name}')
		}
	}
}
