# Taiga Client

Taiga client using VLang

## Generate Wiki

- Export user, project, story, issue and task as md files to generate a wiki
- Export users, projects as md files to list them with a link for each element.

### Steps
1. Export your taiga credentials in form of username:password in TAIGA
```
export TAIGA=username:password
```
2. Make sure to update taiga_wiki_test.v with your url.
3. Run it in your terminal:
```sh
v run taiga_wiki_test.v
```
3. Booom! Wiki generated :D
