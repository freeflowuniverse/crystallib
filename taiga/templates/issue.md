# @issue.subject

[@issue.subject](@url/@{issue.file_name})

|             |                                                                                 |
| ----------- | ------------------------------------------------------------------------------- |
| Owner       | @issue.owner_extra_info.username                                                |
| Assigned to | @issue.assigned_to_extra_info.username                                          |
| Created at  | @issue.created_date.ymmdd()                                                     |
| Last Update | @issue.modified_date.ymmdd()                                                    |
| Project     | [@{project.name}](@{project.file_name}) |

@if issue.description != ""

## Description

> Rendered as markdown

@issue.description

@end

@if issue.comments.len >0
## Comments
@for comment in issue.comments

> <strong>$comment.user.name</strong> `$comment.created_at`

$comment.comment

@end
@end