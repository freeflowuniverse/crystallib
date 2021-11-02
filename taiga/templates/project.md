
## @project.name
- ID: @project.id
- Private: @project.is_private
- Description: @project.description
- Owner: @project.owner.username

@if stories.len >0
### Stories
@for story in stories
#### $story.subject
- ID: $story.id
- Private: $story.is_private
- Is closed: $story.is_closed
---
@end
@end

@if issues.len >0
### Issues
@for issue in issues
#### $issue.subject
- ID: $issue.id
- Private: $issue.is_private
- Is closed: $issue.is_closed
---
@end
@end

@if tasks.len >0
### Tasks
@for task in tasks
#### $task.subject
- ID: $task.id
- Private: $task.is_private
- Is closed: $task.is_closed
---
@end
@end

@if epics.len >0

### Epics
@for epic in epics
#### $epic.subject
- ID: $epic.id
- Private: $epic.is_private
- Is closed: $epic.is_closed
---
@end
@end
