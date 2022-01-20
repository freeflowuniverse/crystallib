# Projects

| Name | Links |
| ---- | ----- |
@for project in all_projects
| $project.name | [wiki](./projects/$project.file_name) \| [web](@url/project/$project.slug) |
@end
