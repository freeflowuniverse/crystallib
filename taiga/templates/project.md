
## [@project.name](@circles_url/project/@project.slug)
|              |                         |
| ------------ | ----------------------- |
| ID           | @project.id             |
| Private      | @project.is_private     |
| Description  | @project.description    |
| Owner        | @project.owner.username |
| Type         | @project.projtype       |
| Created at   | @project.created_date   |
| Last Updates | @project.modified_date  |

@if stories.len >0
### Stories
@for story in stories
#### [$story.subject](@circles_url/project/@project.slug/us/$story.ref)
|              |                                        |
| ------------ | -------------------------------------- |
| ID           | $story.id                              |
| Owner        | $story.owner_extra_info.username       |
| Assigned to  | $story.assigned_to_extra_info.username |
| Private      | $story.is_private                      |
| Closed       | $story.is_closed                       |
| Created at   | $story.created_date                    |
| Last Updates | $story.modified_date                   |

@if story.description != ""
##### Description
> Rendered as markdown

$story.description

@end

@if story.comments.len >0
##### Comments
@for comment in story.comments

> <strong>$comment.user.name</strong> `$comment.created_at`

$comment.comment

@end <!-- End Comments Loop -->
@end <!-- End Comments Condition -->
---
@end <!-- End Stories Loop -->
@end <!-- End Stories Condition -->

@if issues.len >0
### Issues
@for issue in issues
#### [$issue.subject](@circles_url/project/@project.slug/issue/$issue.ref)
|              |                                        |
| ------------ | -------------------------------------- |
| ID           | $issue.id                              |
| Owner        | $issue.owner_extra_info.username       |
| Assigned to  | $issue.assigned_to_extra_info.username |
| Private      | $issue.is_private                      |
| Closed       | $issue.is_closed                       |
| Created at   | $issue.created_date                    |
| Last Updates | $issue.modified_date                   |

@if issue.description != ""
##### Description
> Rendered as markdown

$issue.description

@end

@if issue.comments.len >0
##### Comments
@for comment in issue.comments
> <strong>$comment.user.name</strong> `$comment.created_at`

$comment.comment

@end
@end
---
@end
@end

@if tasks.len >0
### Tasks
@for task in tasks
#### [$task.subject](@circles_url/project/@project.slug/task/$task.ref)
|              |                                       |
| ------------ | ------------------------------------- |
| ID           | $task.id                              |
| Story        | [$task.user_story_extra_info.subject](#$task.user_story_extra_info.subject.replace(" ", "-").to_lower())   |
| Owner        | $task.owner_extra_info.username       |
| Assigned to  | $task.assigned_to_extra_info.username |
| Private      | $task.is_private                      |
| Closed       | $task.is_closed                       |
| Created at   | $task.created_date                    |
| Last Updates | $task.modified_date                   |

@if task.description != ""
##### Description
> Rendered as markdown

$task.description

@end

@if task.comments.len >0
##### Comments
@for comment in task.comments
> <strong>$comment.user.name</strong> `$comment.created_at`

$comment.comment

@end
@end
---
@end
@end

@if epics.len >0

### Epics
@for epic in epics
#### [$epic.subject](@circles_url/project/@project.slug/epic/$epic.ref)
|              |                                       |
| ------------ | ------------------------------------- |
| ID           | $epic.id                              |
| Story        | [$epic.user_story_extra_info.subject](#$epic.user_story_extra_info.subject.replace(" ", "-").to_lower())   |
| Owner        | $epic.owner_extra_info.username       |
| Assigned to  | $epic.assigned_to_extra_info.username |
| Private      | $epic.is_private                      |
| Closed       | $epic.is_closed                       |
| Created at   | $epic.created_date                    |
| Last Updates | $epic.modified_date                   |

@if epic.description != ""
##### Description
> Rendered as markdown

$epic.description

@end
---
@end
@end
