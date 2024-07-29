module farmingsimulator

import freeflowuniverse.crystallib.core.playbook

pub struct ParamsCultivation {
pub mut:
	utilization_nodes  string = '1:0,24:70'
	revenue_per_cu_usd string = '1:5,60:4'
	revenue_per_su_usd string = '1:5,60:3'
	revenue_per_nu_usd string = '1:0.01,60:0.005'
	cost_per_cu_usd    string = '1:0'
	cost_per_su_usd    string = '1:0'
	cost_per_nu_usd    string = '1:0.005,60:0.0025'
}

pub struct ParamsEnvironment {
pub mut:
	power_cost     string = '1:0.06,60:0.15'
	rackspace_cost string = '1:10,60:5'
}

pub struct ParamsFarming {
pub mut:
	farming_lockup          int    = 24
	farming_min_utilizaton  int    = 30
	price_increase_nodecost string = '1:1,60:0.4'
	support_cost_node       string = '1:20'
}

pub struct ParamsTokens {
pub mut:
	chi_total_tokens_million int    = 1000
	chi_price_usd            string = '1:0.1'
}

pub struct Params {
pub mut:
	wiki_path   string = '/tmp/simulatorwiki'
	cultivation ParamsCultivation
	env         ParamsEnvironment
	farming     ParamsFarming
	tokens      ParamsTokens
}

// TODO: check carefully

pub fn params_new(parser playbook.PlayBook) !Params {
	mut p := Params{}

	for action in parser.actions {
		if action.name == 'cultivation_params_define' {
			mut pc := ParamsCultivation{}
			if action.params.exists('utilization_nodes') {
				pc.utilization_nodes = action.params.get('utilization_nodes')!
			}
			if action.params.exists('revenue_per_cu_usd') {
				pc.revenue_per_cu_usd = action.params.get('revenue_per_cu_usd')!
			}
			if action.params.exists('revenue_per_su_usd') {
				pc.revenue_per_su_usd = action.params.get('revenue_per_su_usd')!
			}
			if action.params.exists('revenue_per_nu_usd') {
				pc.revenue_per_nu_usd = action.params.get('revenue_per_nu_usd')!
			}
			if action.params.exists('cost_per_cu_usd') {
				pc.cost_per_cu_usd = action.params.get('cost_per_cu_usd')!
			}
			if action.params.exists('cost_per_su_usd') {
				pc.cost_per_su_usd = action.params.get('cost_per_su_usd')!
			}
			if action.params.exists('cost_per_nu_usd') {
				pc.cost_per_nu_usd = action.params.get('cost_per_nu_usd')!
			}
			p.cultivation = pc
		}
		if action.name == 'cultivation_params_define' {
			mut pe := ParamsEnvironment{}
			if action.params.exists('power_cost') {
				pe.power_cost = action.params.get('power_cost')!
			}
			if action.params.exists('rackspace_cost') {
				pe.rackspace_cost = action.params.get('rackspace_cost')!
			}
			p.env = pe
		}

		if action.name == 'farming_params_define' {
			mut pf := ParamsFarming{}
			if action.params.exists('farming_lockup') {
				pf.farming_lockup = action.params.get_int('farming_lockup')!
			}
			if action.params.exists('farming_min_utilizaton') {
				pf.farming_min_utilizaton = action.params.get_int('farming_min_utilizaton')!
			}
			if action.params.exists('price_increase_nodecost') {
				pf.price_increase_nodecost = action.params.get('price_increase_nodecost')!
			}
			if action.params.exists('support_cost_node') {
				pf.support_cost_node = action.params.get('support_cost_node')!
			}
			p.farming = pf
		}

		if action.name == 'token_params_define' {
			mut pt := ParamsTokens{}
			if action.params.exists('chi_price_usd') {
				pt.chi_price_usd = action.params.get('chi_price_usd')!
			}
			if action.params.exists('chi_total_tokens_million') {
				pt.chi_total_tokens_million = action.params.get_int('chi_total_tokens_million')!
			}
			p.tokens = pt
		}
		if action.name == 'simulator_params_define' {
			if action.params.exists('wiki_path') {
				p.wiki_path = action.params.get('wiki_path')!
			}
		}
	}
	return p
}
