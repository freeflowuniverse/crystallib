# @story.subject

> [@story.subject](@url/project/@story.project_extra_info.slug/us/$story.ref)

|             |                                                                       |
| ----------- | --------------------------------------------------------------------- |
| Owner       | @story.owner_extra_info.username                                      |
| Assigned to | @story.assigned_to_extra_info.username                                |
| Created at  | @story.created_date.ymmdd()                                           |
| Last Update | @story.modified_date.ymmdd()                                          |
| Project     | [@story.project_extra_info.name](@story.project_extra_info.file_name) |

@if story.description != ""
## Description

> Rendered as markdown

@story.description

@end

@if story.comments.len >0
## Comments
@for comment in story.comments

> <strong>$comment.user.name</strong> `$comment.created_at`

$comment.comment

@end
@end

@if tasks.len >0
## Tasks
| Subject | Owner | Assigned to | Last Update | Deadline | Close Status | # Comments | Link |
| ------- | ----- | ----------- | ----------- | -------- | ------------ | ---------- | ---- |

@for task in tasks
| $task.subject | $task.owner_extra_info.username | $task.assigned_to_extra_info.username | $task.modified_date.ymmdd() | $task.due_date.ymmdd() | $task.is_closed | $task.total_comments | [wiki]($task.file_name) \| [web](@url/project/@story.project_extra_info.slug/task/$task.ref) |
@end
@end
