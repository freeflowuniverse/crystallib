# [@task.subject](@url/project/@task.project_extra_info.slug/task/@task.ref)

|             |                                                                                         |
| ----------- | --------------------------------------------------------------------------------------- |
| Owner       | @task.owner_extra_info.username                                                         |
| Assigned to | @task.assigned_to_extra_info.username                                                   |
| Created at  | @task.created_date.ymmdd()                                                              |
| Last Update | @task.modified_date.ymmdd()                                                             |
@if task.user_story != 0
| Story       | [@task.user_story_extra_info.subject](@task.user_story_extra_info.file_name) |
@end
| Project     | [@task.project_extra_info.name](@task.project_extra_info.file_name)         |

@if task.description != ""

## Description

> Rendered as markdown

@task.description

@end

@if task.comments.len >0
## Comments
@for comment in task.comments

> <strong>$comment.user.name</strong> `$comment.created_at`

$comment.comment

@end
@end