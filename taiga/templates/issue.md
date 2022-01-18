

# [$issue.subject](@circles_url/issue/@issue.slug/us/$issue.ref)

|             |                                        |
| ----------- | -------------------------------------- |
| Owner       | $issue.owner_extra_info.username       |
| Assigned to | $issue.assigned_to_extra_info.username |
| Created at  | $issue.created_date                    |
| Last Update | $issue.modified_date                   |

@if issue.description != ""

##### Description

> Rendered as markdown

$issue.description

@end

@if task.description != ""


@if issue.comments.len >0
##### Comments
@for comment in issue.comments

> <strong>$comment.user.name</strong> `$comment.created_at`

$comment.comment





