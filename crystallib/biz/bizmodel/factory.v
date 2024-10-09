module bizmodel

import freeflowuniverse.crystallib.biz.spreadsheet

__global (
	bizmodels shared map[string]BizModel
)

// get bizmodel from global
pub fn get(name string) !BizModel {
	rlock bizmodels {
		if ! (name in bizmodels) {
			mut sh := spreadsheet.sheet_new(name: 'bizmodel_${name}')!
			mut bizmodel := BizModel{
				sheet: &sh
				name:name
				// currencies: cs
			}		
			set(bizmodel)
			
		}
		return bizmodels[name] or { panic("bug") }
	}
	return error("cann't find biz model:'${name}' in global bizmodels")
}

pub fn set(bizmodel BizModel) {

	rlock bizmodels {
		bizmodels[bizmodel.name] = bizmodel
	}

}