module bizmodel

import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.data.markdownparser.elements
import freeflowuniverse.crystallib.ui.console

pub fn playmacro(action playbook.Action) !string {
	p := action.params

	bizname:=action.params.get("bizname")!

	mut sim:=get(bizname)!

	if action.name == 'employee_wiki' {
		console.print_green('playmacro node_wiki')
		id := p.get_default('id', '')!
		if id !in sim.employees {
			return error('employee with id <${id}> not found')
		}
		employee := sim.employees[id] or { panic("bug") }

		employee_table := elements.Table{
			header: [
				&elements.Paragraph{content:'Key'},
				&elements.Paragraph{content:'Value'}
			]
			rows: [
				elements.Row{ [
					&elements.Paragraph{content:'cost'},
					&elements.Paragraph{content:employee.cost}
				]},
				elements.Row{ [
					&elements.Paragraph{content:'department'},
					&elements.Paragraph{content:employee.department}
				]},
				elements.Row{ [
					&elements.Paragraph{content:'indexation'},
					&elements.Paragraph{content:"${employee.indexation}"}
				]}
			]
			alignments: [.left, .left]
		}.markdown()!
		return $tmpl('./templates/employee.md')
	}

	return error("couldn't find macro '${action.name}' for bizmodel.")

}
