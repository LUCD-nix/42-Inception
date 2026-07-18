*This project has been created as part of the 42 curriculum by lucorrei*

# Description
The goal of this project was to learn how Docker Compose and Docker images work by creating and running a simple Wordpress blog.

# Instruction
- Ensure you have git, a docker runtime (docker.io package in the Debian repos) docker-cli, and docker-compose, as well as Make.
- Clone this repo and `cd` into it.
- Run `make up`, the Makefile will build and run the images (and print the commands it uses).

# Resources
## Reading material:
- The Dockerfile and Docker compose references located  [here](https://docs.docker.com/reference/)
- A sample [Wordpress + MariaDB configuration](https://github.com/docker/awesome-compose/tree/master/official-documentation-samples/wordpress/)
- This [article](https://www.dchost.com/blog/en/wordpress-on-docker-compose-without-the-drama-nginx-mariadb-redis-persistent-volumes-auto%E2%80%91backups-and-a-calm-update-flow/) showing a simple setup with healthchecks inside the compose file.

## A.I. disclosure:
- "Conversational" AI was used as a way to better grok the extensive and sometimes confusing documentation of the various tools and services.
- Agentic AI was used as a large-scale refactoring tool such as when moving environment variables to the .env and secrets files.
