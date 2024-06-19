module generator

import freeflowuniverse.crystallib.core.codemodel { CodeFile, CodeItem, Function, Import, Param, Struct, StructField, Type }
import freeflowuniverse.crystallib.core.codeparser
import freeflowuniverse.crystallib.core.texttools
import os

pub fn (gen ActorGenerator) generate_object_code(params_ GenerateCrudMethods) CodeFile {
	object_name := texttools.name_fix(params_.root_struct.name)
	object_type := params_.root_struct.name
	params := GenerateCrudMethods{
		...params_
		object_type: params_.root_struct.name
		object_name: object_name
	}
	mut file := codemodel.new_file(
		mod: gen.model_name
		name: object_name
		imports: [
			Import{
				mod: '${params.root_struct.mod}'
				types: [object_type]
			},
			Import{
				mod: 'freeflowuniverse.crystallib.baobab.backend'
				types: ['FilterParams']
			},
		]
		items: [
			gen.generate_get_method(params),
			gen.generate_read_method(params),
			gen.generate_update_method(params),
			gen.generate_delete_method(params),
			gen.generate_list_method(params),
		]
	)
	filter_params := gen.generate_filter_params(params)
	file.items << filter_params.map(CodeItem(it))
	file.items << gen.generate_filter_method(params)
	return file
}

@[params]
pub struct GenerateCrudMethods {
pub:
	actor_name  string      @[required] // name of actor struct
	object_type string
	actor_field StructField // field in actor belonging to root object
	root_struct Struct
	object_name string
}

// generate_object_methods generates CRUD actor methods for a provided structure
pub fn (generator ActorGenerator) generate_object_methods(params GenerateCrudMethods) []Function {
	return [
		generator.generate_get_method(params),
		generator.generate_read_method(params),
		generator.generate_update_method(params),
		generator.generate_delete_method(params),
		generator.generate_list_method(params),
		// generator.generate_filter_method(params),
	]
}

// generate_object_methods generates CRUD actor methods for a provided structure
fn (generator ActorGenerator) generate_read_method(params GenerateCrudMethods) Function {
	get_method := Function{
		name: 'read_${params.object_name}'
		description: 'gets the ${params.object_name} with the given object id'
		receiver: Param{
			mutable: true
			name: 'actor'
			typ: Type{
				symbol: params.actor_name
			}
		}
		params: [
			Param{
				name: 'id'
				typ: Type{
					symbol: 'int'
				}
			},
		]
		result: codemodel.Result{
			typ: Type{
				symbol: params.root_struct.name
			}
			result: true
		}
		body: 'return actor.backend.get[${params.object_type}](id)!'
	}
	return get_method
}

// generate_object_methods generates CRUD actor methods for a provided structure
fn (generator ActorGenerator) generate_update_method(params GenerateCrudMethods) Function {
	param_getters := generate_param_getters(
		structure: params.root_struct
		prefix: ''
		only_mutable: true
	)
	body := 'actor.backend.set[${params.object_type}](${params.object_name})!'
	get_method := Function{
		name: 'update_${params.root_struct.name.to_lower()}'
		description: 'gets the ${params.root_struct.name} with the given object id'
		receiver: Param{
			mutable: true
			name: 'actor'
			typ: Type{
				symbol: params.actor_name
			}
		}
		params: [
			Param{
				name: params.object_name
				typ: Type{
					symbol: params.object_type
				}
			},
		]
		result: codemodel.Result{
			result: true
		}
		body: body
	}
	return get_method
}

// generate_object_methods generates CRUD actor methods for a provided structure
fn (generator ActorGenerator) generate_delete_method(params GenerateCrudMethods) Function {
	body := 'actor.backend.delete[${params.object_type}](id)!'
	get_method := Function{
		name: 'delete_${params.root_struct.name.to_lower()}'
		description: 'deletes the ${params.root_struct.name} with the given object id'
		receiver: Param{
			mutable: true
			name: 'actor'
			typ: Type{
				symbol: params.actor_name
			}
		}
		params: [
			Param{
				name: 'id'
				typ: Type{
					symbol: 'int'
				}
			},
		]
		result: codemodel.Result{
			result: true
		}
		body: body
	}
	return get_method
}

// generate_object_methods generates CRUD actor methods for a provided structure
fn (generator ActorGenerator) generate_get_method(params GenerateCrudMethods) Function {
	param_getters := generate_param_getters(
		structure: params.root_struct
		prefix: ''
		only_mutable: false
	)
	body := 'return actor.backend.new[${params.object_type}](${params.object_name})!'
	create_method := Function{
		name: 'create_${params.root_struct.name.to_lower()}'
		description: 'creates the ${params.root_struct.name} with the given object id'
		receiver: Param{
			name: 'actor'
			typ: Type{
				symbol: params.actor_name
			}
			mutable: true
		}
		params: [
			Param{
				name: params.object_name
				typ: Type{
					symbol: params.object_type
				}
			},
		]
		result: codemodel.Result{
			result: true
			typ: Type{
				symbol: 'int'
			}
		}
		body: body
	}
	return create_method
}

// generate_object_methods generates CRUD actor methods for a provided structure
fn (generator ActorGenerator) generate_list_method(params GenerateCrudMethods) Function {
	param_getters := generate_param_getters(
		structure: params.root_struct
		prefix: ''
		only_mutable: false
	)
	body := 'return actor.backend.list[${params.object_type}]()!'
	create_method := Function{
		name: 'list_${params.root_struct.name.to_lower()}'
		description: 'lists all of the ${params.object_name} objects'
		receiver: Param{
			name: 'actor'
			typ: Type{
				symbol: params.actor_name
			}
			mutable: true
		}
		params: []
		result: codemodel.Result{
			typ: Type{
				symbol: '[]${params.object_type}'
			}
			result: true
		}
		body: body
	}
	return create_method
}

fn (generator ActorGenerator) generate_filter_params(params GenerateCrudMethods) []Struct {
	return [
		Struct{
			name: 'Filter${params.object_type}Params'
			fields: [
				StructField{
					name: 'filter'
					typ: Type{
						symbol: '${params.object_type}Filter'
					}
				},
				StructField{
					name: 'params'
					typ: Type{
						symbol: 'FilterParams'
					}
				},
			]
		},
		Struct{
			name: '${params.object_type}Filter'
			fields: params.root_struct.fields.filter(it.attrs.any(it.name == 'index'))
		},
	]
}

// generate_object_methods generates CRUD actor methods for a provided structure
fn (generator ActorGenerator) generate_filter_method(params GenerateCrudMethods) Function {
	param_getters := generate_param_getters(
		structure: params.root_struct
		prefix: ''
		only_mutable: false
	)
	params_type := 'Filter${params.object_type}Params'
	body := 'return actor.backend.filter[${params.object_type}, ${params.object_type}Filter](filter.filter, filter.params)!'
	return Function{
		name: 'filter_${params.object_name}'
		description: 'lists all of the ${params.object_name} objects'
		receiver: Param{
			name: 'actor'
			typ: Type{
				symbol: params.actor_name
			}
			mutable: true
		}
		params: [
			Param{
				name: 'filter'
				typ: Type{
					symbol: params_type
				}
			},
		]
		result: codemodel.Result{
			typ: Type{
				symbol: '[]${params.object_type}'
			}
			result: true
		}
		body: body
	}
}

@[params]
struct GenerateParamGetters {
	structure    Struct
	prefix       string
	only_mutable bool // if true generates param.get methods for only mutable  struct fields. Used for updating.
}

fn generate_param_getters(params GenerateParamGetters) []string {
	mut param_getters := []string{}
	fields := if params.only_mutable {
		params.structure.fields.filter(it.is_mut && it.is_pub)
	} else {
		params.structure.fields.filter(it.is_pub)
	}
	for field in fields {
		if field.typ.symbol.starts_with_capital() {
			subgetters := generate_param_getters(GenerateParamGetters{
				...params
				structure: field.structure
				prefix: '${field.name}_'
			})
			// name of the tested object, used for param declaration
			// ex: fruits []Fruit becomes fruit_name
			nested_name := field.structure.name.to_lower()
			if field.typ.is_map {
				param_getters.insert(0, '${nested_name}_key := params.get(\'${nested_name}_key\')!')
				param_getters << '${field.name}: {${nested_name}_key: ${field.structure.name}}{'
			} else if field.typ.is_array {
				param_getters << '${field.name}: [${field.structure.name}{'
			} else {
				param_getters << '${field.name}: ${field.structure.name}{'
			}
			param_getters << subgetters
			param_getters << if field.typ.is_array { '}]' } else { '}' }
			continue
		}

		mut get_method := '${field.name}: params.get'
		if field.typ.symbol != 'string' {
			// TODO: check if params method actually exists
			'get_${field.typ.symbol}'
		}

		if field.default != '' {
			get_method += '_default'
		}

		get_method = get_method + "('${params.prefix}${field.name}')!"
		param_getters << get_method
	}
	return param_getters
}

@[params]
struct GetChildField {
	parent Struct @[required]
	child  Struct @[required]
}

fn get_child_field(params GetChildField) StructField {
	fields := params.parent.fields.filter(it.typ.symbol == 'map[string]&${params.child.name}')
	if fields.len != 1 {
		panic('this should never happen')
	}
	return fields[0]
}
