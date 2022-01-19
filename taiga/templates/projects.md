# Projects

| Name | Links |
| ---- | ----- |
@for project in all_projects
| $project.name | [link](@url/project/$project.slug) \| [md](./projects/$project.file_name) |
@end
