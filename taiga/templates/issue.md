# @issue.subject

> [@issue.subject](@url/project/@issue.project().slug/issue/@issue.ref)

|             |                                         |
| ----------- | --------------------------------------- |
| Owner       | @issue.owner().username                 |
| Assigned to | @issue.assigned_as_str()                |
| Created at  | @issue.created_date.ymmdd()             |
| Last Update | @issue.modified_date.ymmdd()            |
| Project     | [@{issue.project().name}](@issue.project().file_name) |

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