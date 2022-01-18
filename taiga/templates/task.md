

# [$task.subject](@circles_url/task/@task.slug/us/$task.ref)

|             |                                        |
| ----------- | -------------------------------------- |
| Owner       | $task.owner_extra_info.username       |
| Assigned to | $task.assigned_to_extra_info.username |
| Created at  | $task.created_date                    |
| Last Update | $task.modified_date                   |

@if task.description != ""

##### Description

> Rendered as markdown

$task.description

@end

@if task.description != ""


@if task.comments.len >0
##### Comments
@for comment in task.comments

> <strong>$comment.user.name</strong> `$comment.created_at`

$comment.comment
