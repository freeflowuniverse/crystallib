# @project.name

> [@project.name](@url/project/@project.slug)

|              |                                |
| ------------ | ------------------------------ |
| ID           | @project.id                    |
| Private      | @project.is_private            |
| Description  | @project.description           |
| Owner        | @project.owner().username      |
| Created at   | @project.created_date.ymmdd()  |
| Last Updates | @project.modified_date.ymmdd() |

@if project.stories().len > 0

## Stories

| Subject | Owner | Assigned to | Created at | Last Update | Link |
| ------- | ----- | ----------- | ---------- | ----------- | ---- |

@for story in project.stories()
| $story.subject | $story.owner().username | $story.assigned_as_str() | $story.created_date.ymmdd() | $story.modified_date.ymmdd() | [wiki]($story.file_name) \| [web](@url/project/@project.slug/us/$story.ref) |
@end <!-- End Stories Loop -->
@end <!-- End Stories Condition -->

@if project.issues().len > 0

## Issues

| Subject | Owner | Assigned to | Created at | Last Update | Close Status | Link |
| ------- | ----- | ----------- | ---------- | ----------- | ------------ | ---- |

@for issue in project.issues()
| $issue.subject | $issue.owner().username | $issue.assigned_as_str() | $issue.created_date.ymmdd() | $issue.modified_date.ymmdd() | $issue.is_closed |[wiki]($issue.file_name) \| [web](@url/project/@project.slug/issue/$issue.ref) |
@end <!-- End Issues Loop -->
@end <!-- End Issues Condition -->

@if project.tasks().len > 0

## Tasks

| Subject | Owner | Assigned to | Created at | Last Update | Close Status | Link |
| ------- | ----- | ----------- | ---------- | ----------- | ------------ | ---- |

@for task in project.tasks()
| $task.subject | $task.owner().username | $task.assigned_as_str() | $task.created_date.ymmdd() | $task.modified_date.ymmdd() | $task.is_closed |[wiki]($task.file_name) \| [web](@url/project/@project.slug/task/$task.ref) |
@end <!-- End Tasks Loop -->
@end <!-- End Tasks Condition -->
