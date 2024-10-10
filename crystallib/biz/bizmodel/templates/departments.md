
@for dept in deps

@if dept.title.len>0
## @{dept.title}
@else
## @{dept.name}
@end

| Name | Title | Nr People |
|------|-------|-------|
@for employee in sim.employees.values().filter(it.department == dept.name)
| @{employee_names[employee.name]} | @{employee.title} | @{employee.nrpeople} |
@end

@end