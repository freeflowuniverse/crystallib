# [@project.name](@url/project/@project.slug)
|              |                         |
| ------------ | ----------------------- |
| ID           | @project.id             |
| Private      | @project.is_private     |
| Description  | @project.description    |
| Owner        | @project.owner.username |
| Created at   | @project.created_date   |
| Last Updates | @project.modified_date  |

@if stories.len >0
## Stories
| Subject | Owner | Assigned to | Created at | Last Update | Link |
| ------- | ----- | ----------- | ---------- | ----------- | ---- |
@for story in stories
| $story.subject | $story.owner_extra_info.username | $story.assigned_to_extra_info.username | $story.created_date.ymmdd() | $story.modified_date.ymmdd() | [wiki](../stories/$story.file_name) \| [web](@url/project/@project.slug/us/$story.ref) |
@end <!-- End Stories Loop -->
@end <!-- End Stories Condition -->

@if issues.len >0
## Issues
| Subject | Owner | Assigned to | Created at | Last Update | Close Status | Link |
| ------- | ----- | ----------- | ---------- | ----------- | ------------ | ---- |
@for issue in issues
| $issue.subject | $issue.owner_extra_info.username | $issue.assigned_to_extra_info.username | $issue.created_date.ymmdd() | $issue.modified_date.ymmdd() | $issue.is_closed |[wiki](../issues/$issue.file_name) \| [web](@url/project/@project.slug/issue/$issue.ref) |
@end <!-- End Issues Loop -->
@end <!-- End Issues Condition -->

@if tasks.len >0
## Tasks
| Subject | Owner | Assigned to | Created at | Last Update | Close Status | Link |
| ------- | ----- | ----------- | ---------- | ----------- | ------------ | ---- |
@for task in tasks
| $task.subject | $task.owner_extra_info.username | $task.assigned_to_extra_info.username | $task.created_date.ymmdd() | $task.modified_date.ymmdd() | $task.is_closed |[wiki](../tasks/$task.file_name) \| [web](@url/project/@project.slug/task/$task.ref) |
@end <!-- End Tasks Loop -->
@end <!-- End Tasks Condition -->

@if epics.len >0
## Epics
| Subject | Owner | Assigned to | Created at | Last Update | Close Status | Link |
| ------- | ----- | ----------- | ---------- | ----------- | ------------ | ---- |
@for epic in epics
| $epic.subject | $epic.owner_extra_info.username | $epic.assigned_to_extra_info.username | $epic.created_date.ymmdd() | $epic.modified_date.ymmdd() | $epic.is_closed |[wiki](../epics/$epic.file_name) \| [web](@url/project/@project.slug/epic/$epic.ref) |
@end  <!-- End Epics Loop -->
@end <!-- End Epics Condition -->
