# @story.subject

> [@story.subject](@url/project/@story.project().slug/us/@story.ref)

|             |                                                     |
| ----------- | --------------------------------------------------- |
| Owner       | @story.owner().username                             |
| Assigned to | @story.assigned_as_str()                            |
| Created at  | @story.created_date.ymmdd()                         |
| Last Update | @story.modified_date.ymmdd()                        |
| Project     | [@story.project().name](@story.project().file_name) |

@if story.description != ""
## Description

> Rendered as markdown

@story.description

@end

@if story.comments.len > 0
## Comments
@for comment in story.comments

> <strong>$comment.user().username</strong> `$comment.created_at`

    $comment.comment

@end
@end

@if story.tasks().len > 0

## Tasks

| Subject | Owner | Assigned to | Last Update | Deadline | Close Status | # Comments | Link |
| ------- | ----- | ----------- | ----------- | -------- | ------------ | ---------- | ---- |

@for task in story.tasks()
| $task.subject | $task.owner().username | $task.assigned_as_str() | $task.modified_date.ymmdd() | $task.due_date.ymmdd() | $task.is_closed | $task.comments.len | [wiki]($task.file_name) \| [web](@url/project/@story.project().slug/task/$task.ref) |

@end
@end
