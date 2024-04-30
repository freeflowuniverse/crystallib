module generator

import freeflowuniverse.crystallib.core.codemodel {Import,Struct, CodeFile, CustomCode, Function, CodeItem, Type}
import freeflowuniverse.crystallib.core.codeparser
import freeflowuniverse.crystallib.core.texttools
import os

// generate_object_methods generates CRUD actor methods for a provided structure
pub fn (generator ActorGenerator) generate_object_test_code(params GenerateCrudMethods) !CodeFile {
	consts := CustomCode{"const db_dir = '\${os.home_dir()}/hero/db'
const actor_name = '${params.actor_name}_test_actor'"}

	clean_code := "if os.exists('\${db_dir}/\${actor_name}') {
		os.rmdir_all('\${db_dir}/\${actor_name}')!
	}
	if os.exists('\${db_dir}/\${actor_name}.sqlite') {
		os.rm('\${db_dir}/\${actor_name}.sqlite')!
	}	"

	testsuite_begin := Function {
		name: 'testsuite_begin'
		body: clean_code
	}

	testsuite_end := Function {
		name: 'testsuite_end'
		body: clean_code
	}

	object_name := texttools.name_fix(params.root_struct.name)
	object_type := params.root_struct.name
	// TODO: support modules outside of crystal
	return CodeFile{
		name: '${object_name}_test'
		mod: texttools.name_fix(params.actor_name)
		imports: [
			Import{mod: 'os'},
			Import{
				mod: '${params.root_struct.mod}'
				types: [object_type]
			}
		]
		items: [
			consts,
			testsuite_begin,
			testsuite_end,
			generator.generate_create_method_test(GenerateCrudMethods
			{...params, 
				object_name: object_name
				object_type: object_type
	})!, generator.generate_filter_test(GenerateCrudMethods
			{...params, 
				object_name: object_name
				object_type: object_type
	})!	
		]
	}
}

// generate_object_methods generates CRUD actor methods for a provided structure
fn (generator ActorGenerator) generate_create_method_test(params GenerateCrudMethods) !codemodel.Function {
	required_fields := params.root_struct.fields.filter(it.attrs.any(it.name == 'required'))
	mut fields := []string{}
	for field in required_fields {
		mut field_decl := '${field.name}: '
		field_decl += if field.typ.symbol == 'string' {
			"''"
		} else if field.typ.symbol == 'int' {
			'0'
		} else { return error('Non string or int required fields are not yet supported')}
		fields << field_decl
	}
	body := "mut actor := get(name: actor_name)!
	mut ${params.object_name}_id := actor.create_${params.object_name}(${params.object_type}{${fields.join(',')}})!
	assert ${params.object_name}_id == 1

	${params.object_name}_id = actor.create_${params.object_name}(${params.object_type}{${fields.join(',')}})!
	assert ${params.object_name}_id == 2"
	return codemodel.Function{
		name: 'test_create_${params.object_name}'
		description: 'creates the ${params.object_type} with the given object id'
		result: codemodel.Result{result: true}
		body: body
	}
}

// generate_object_methods generates CRUD actor methods for a provided structure
fn (generator ActorGenerator) generate_filter_test(params GenerateCrudMethods) !codemodel.Function {
	index_fields := params.root_struct.fields.filter(it.attrs.any(it.name == 'index'))
	if index_fields.len == 0 {
		return error('Cannot generate filter method test for object without any index fields')
	}

	mut index_tests := []string{}
	for i, field in index_fields {
		val := get_mock_value(field.typ.symbol)!
		index_field := '${field.name}: ${val}' // index field assignment line
		mut fields := [index_field]
		fields << get_required_fields(params.root_struct)!
		index_tests << "${params.object_name}_id${i} := actor.create_${params.object_name}(${params.object_type}{${fields.join(',')}})!
		${params.object_name}_list${i} := actor.filter_${params.object_name}(
			filter: ${params.object_type}Filter{${index_field}}
		)!
		assert ${params.object_name}_list${i}.len == 1
		assert ${params.object_name}_list${i}[0].${field.name} == ${val}
		"
	}

	body := "mut actor := get(name: actor_name)!
	\n${index_tests.join('\n\n')}"

	return codemodel.Function{
		name: 'test_filter_${params.object_name}'
		description: 'creates the ${params.object_type} with the given object id'
		result: codemodel.Result{result: true}
		body: body
	}
}

fn get_required_fields(s Struct) ![]string {
	required_fields := s.fields.filter(it.attrs.any(it.name == 'required'))
	mut fields := []string{}
	for field in required_fields {
		fields << '${field.name}: ${get_mock_value(field.typ.symbol)!}'
	}
	return fields
}

fn get_mock_value(typ string) !string {
	if typ == 'string' {
		return "'test_string'"
	} else if typ == 'int' {
		return '42'
	} else {
		return error('mock values for types other than strings and ints are not yet supported')
	}
}