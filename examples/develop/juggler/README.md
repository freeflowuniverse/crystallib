## Juggler Example

This example demonstrates how juggler is able to trigger DAG's on a remote dagu server, upon webhook triggers from gitea.

To run example:
- configure gitea webhook to call `trigger` endpoint in your locally running juggler server
- run `main.vsh` with the appropriate `repo_path` and `dagu server url`