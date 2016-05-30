# Bitbucket repository creator

Replaces origin remote configuration of a repository to a new repository on Bitbucket
This script is useful when you have to do a migration from a local server to Bitbucket server
It's possible use this just for a single repository if you want it.

## EXAMPLES:

If you have a directory which contains many repositories
```shell
find * ! -path . -type d -maxdepth 0 -exec bash ./bitbucket_creator.bash your_user your_pass {} \;
```

If you just want migrate a single repository
```shell
bash ./bitbucket_creator.bash your_user your_pass repository
```
