# @issue.subject

> [@issue.subject](@url/project/@project.slug/issue/@issue.ref)

|             |                                       |
| ----------- | ------------------------------------- |
| Owner       | @owner.username                       |
| Assigned to | @assigned_to                          |
| Created at  | @issue.created_date.ymmdd()           |
| Last Update | @issue.modified_date.ymmdd()          |
| Project     | [@{project.name}](@project.file_name) |

@if issue.description != ""

## Description

> Rendered as markdown

@issue.description

@end

@if issue.comments.len >0
## Comments
@for comment in issue.comments

> <strong>$comment.user().username</strong> `$comment.created_at`

    $comment.comment

@end
@end