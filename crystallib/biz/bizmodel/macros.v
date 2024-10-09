module bizmodel

import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.data.markdownparser.elements
import freeflowuniverse.crystallib.ui.console

pub fn playmacro(action playbook.Action) !string {
	p := action.params

	bizname:=action.params.get("bizname") or {
		return error("Can't find param:'bizname' for action: ${action.name}, please specify as bizname: ...")
	}

	mut sim:=get(bizname)!

	if action.name == 'employee_wiki' {
		console.print_green('playmacro node_wiki')
		mut id := p.get_default('id', '')!
		if id !in sim.employees {
			id = p.get_default('name', '')!
			if id !in sim.employees {
				return error('employee with name <${id}> not found')
			}
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
		mut t:=$tmpl('./templates/employee.md')
		return t
	}

	return error("couldn't find macro '${action.name}' for bizmodel.")

}
