module actorgenerator

import freeflowuniverse.crystallib.core.codemodel
import freeflowuniverse.crystallib.core.codeparser
import os

@[params]
struct GenerateCrudMethods {
pub:
	actor_name  string                @[required] // name of actor struct
	actor_field codemodel.StructField @[required] // field in actor belonging to root object
	root_struct codemodel.Struct      @[required]
}

// generate_crud_methods generates CRUD actor methods for a provided structure
pub fn (generator ActorGenerator) generate_crud_methods(params GenerateCrudMethods) []codemodel.Function {
	return [
		generator.generate_get_method(params),
		generator.generate_set_method(params),
		generator.generate_delete_method(params),
		generator.generate_create_method(params),
	]
}

// generate_crud_methods generates CRUD actor methods for a provided structure
fn (generator ActorGenerator) generate_get_method(params GenerateCrudMethods) codemodel.Function {
	body := '
id := params.get(\'id\')!
mut object := ${params.root_struct.name}{}
rlock actor {
	object = actor.${params.actor_field.name}[id]
}'
	get_method := codemodel.Function{
		name: 'get_${params.root_struct.name.to_lower()}'
		description: 'gets the ${params.root_struct.name} with the given object id'
		receiver: codemodel.Param{
			is_shared: true
			name: 'actor'
			typ: codemodel.Type{
				symbol: params.actor_name
			}
		}
		params: [
			codemodel.Param{
				name: 'params'
				typ: codemodel.Type{
					symbol: 'Params'
				}
			},
		]
		result: codemodel.Result{
			structure: params.root_struct
			result: true
		}
		body: body
	}
	return get_method
}

// generate_crud_methods generates CRUD actor methods for a provided structure
fn (generator ActorGenerator) generate_set_method(params GenerateCrudMethods) codemodel.Function {
	param_getters := generate_param_getters(
		structure: params.root_struct
		prefix: ''
		only_mutable: true
	)
	body := "
id := params.get('id')!
if id !in actor.${params.actor_field.name} {
    return error('Root object with id does not exists.')
}
lock actor{
	actor.${params.actor_field.name}[id] = ${params.root_struct.name} {
	...actor.${params.actor_field.name}[id]
${param_getters.join('\n')}
}
}"
	get_method := codemodel.Function{
		name: 'set_${params.root_struct.name.to_lower()}'
		description: 'gets the ${params.root_struct.name} with the given object id'
		receiver: codemodel.Param{
			is_shared: true
			name: 'actor'
			typ: codemodel.Type{
				symbol: params.actor_name
			}
		}
		params: [
			codemodel.Param{
				name: 'params'
				typ: codemodel.Type{
					symbol: 'Params'
				}
			},
		]
		result: codemodel.Result{
			structure: params.root_struct
			result: true
		}
		body: body
	}
	return get_method
}

// generate_crud_methods generates CRUD actor methods for a provided structure
fn (generator ActorGenerator) generate_delete_method(params GenerateCrudMethods) codemodel.Function {
	body := '
id := params.get(\'id\')!
lock actor {
	actor.${params.actor_field.name}.delete(id)
}'
	get_method := codemodel.Function{
		name: 'delete_${params.root_struct.name.to_lower()}'
		description: 'deletes the ${params.root_struct.name} with the given object id'
		receiver: codemodel.Param{
			is_shared: true
			name: 'actor'
			typ: codemodel.Type{
				symbol: params.actor_name
			}
		}
		params: [
			codemodel.Param{
				name: 'params'
				typ: codemodel.Type{
					symbol: 'Params'
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

// generate_crud_methods generates CRUD actor methods for a provided structure
fn (generator ActorGenerator) generate_create_method(params GenerateCrudMethods) codemodel.Function {
	param_getters := generate_param_getters(
		structure: params.root_struct
		prefix: ''
		only_mutable: false
	)
	body := "
id := params.get('id')!
if id in actor.${params.actor_field.name} {
    return error('Root object with id already exists.')
}
object := ${params.root_struct.name} {
${param_getters.join('\n')}
}
lock actor{
	actor.${params.actor_field.name}[id] = object
}"
	create_method := codemodel.Function{
		name: 'create_${params.root_struct.name.to_lower()}'
		description: 'creates the ${params.root_struct.name} with the given object id'
		receiver: codemodel.Param{
			name: 'actor'
			typ: codemodel.Type{
				symbol: params.actor_name
			}
			is_shared: true
		}
		params: [
			codemodel.Param{
				name: 'params'
				typ: codemodel.Type{
					symbol: 'Params'
				}
			},
		]
		result: codemodel.Result{
			result: true
		}
		body: body
	}
	return create_method
}

@[params]
struct GenerateParamGetters {
	structure    codemodel.Struct
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
	parent codemodel.Struct @[required]
	child  codemodel.Struct @[required]
}

fn get_child_field(params GetChildField) codemodel.StructField {
	fields := params.parent.fields.filter(it.typ.symbol == 'map[string]&${params.child.name}')
	if fields.len != 1 {
		panic('this should never happen')
	}
	return fields[0]
}
