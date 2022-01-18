# rich client for Taiga

## features

- [ ] easy to get projects, issues, stories, epics
- [ ] create project with 3 predefined types
- [ ] copy issues,stories,epics from one project to other
- [ ] caching in redis (on api level, not for modifications ofcourse, for many of those empty cache)


## directory output for generation


- projects
  - $project_name
    - stories.md
    - issues.md
    - epics.md
    - epics
      - $epicsname_$id.md
    - issues
      - $issuename_$id.md
    - stories
      - $storyname_$id.md



