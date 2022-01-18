

# [$story.subject](@circles_url/project/@project.slug/us/$story.ref)

|             |                                        |
| ----------- | -------------------------------------- |
| Owner       | $story.owner_extra_info.username       |
| Assigned to | $story.assigned_to_extra_info.username |
| Created at  | $story.created_date                    |
| Last Update | $story.modified_date                   |

@if story.description != ""

##### Description

> Rendered as markdown

$story.description

@end


@if tasks.len >0
### Tasks
@for task in tasks

#### [$task.subject](@circles_url/project/@project.slug/task/$task.ref)
|              |                                                                                                          |
| ------------ | -------------------------------------------------------------------------------------------------------- |
| Story        | [$task.user_story_extra_info.subject](#$task.user_story_extra_info.subject.replace(" ", "-").to_lower()) |
| Owner        | $task.owner_extra_info.username                                                                          |
| Assigned to  | $task.assigned_to_extra_info.username                                                                    |
| Closed       | $task.is_closed                                                                                          |
| Last Updates | $task.modified_date                                                                                      |
| Deadline     | ...                                                                                                      |
| Comments     | X nr of comments                                                                                         |

> remark: only show comments above is there are comments, do the link to task page

@if task.description != ""


@if story.comments.len >0
##### Comments
@for comment in story.comments

> <strong>$comment.user.name</strong> `$comment.created_at`

$comment.comment


