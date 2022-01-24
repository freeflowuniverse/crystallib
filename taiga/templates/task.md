# @task.subject

> [@task.subject](@url/project/@task.project().slug/task/@task.ref)
|             |                             |
| ----------- | --------------------------- |
| Owner       | @task.owner().username      |
| Assigned to | @task.assigned_as_str()     |
| Created at  | @task.created_date.ymmdd()  |
| Last Update | @task.modified_date.ymmdd() |
@if task.story().id != 0
| Story       | [@task.story().subject](@task.story().file_name) |
@end
| Project     | [@task.project().name](@task.project().file_name) |
@if task.description != ""

## Description

> Rendered as markdown

@task.description

@end

@if task.comments.len >0
## Comments
@for comment in task.comments

> <strong>$comment.user().username</strong> `$comment.created_at`

$comment.comment

@end
@end