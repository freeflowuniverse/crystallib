# Gitea Client Issue MD Generator example

Example that generates markdown files for issues in `git.ourworld.tf` using the Gitea Client. Issues are fetched from repositories, and the repositories which the issues belong to can be filtered using the `--organizations`, `--users`, `--repositories` flags. For instance `--organizations threefold_coop home` will only create files for issues belonging to repos of these two organizations.

## Run example

To be able to access private resources in git.ourworld.tf export your credentials:

`export GITEA_USERNAME=`
`export GITEA_PASSWORD=`

From the root of the crystallib repository, run the following commands.

`chmod +x examples/clients/gitea/md_issues/gitea.vsh`
`examples/clients/gitea/md_issues/gitea.vsh -o examples/clients/gitea/md_issues/target`

This will create `/users`, `/issues`, `/repositories` in a target directory.

## Purpose

The script can be used or modified to create mdbooks for issues and users.