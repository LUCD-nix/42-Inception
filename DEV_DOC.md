*This document assumes you want to build and run the project on your machine/server. If you just want to inspect what it's doing or change its configuration at runtime, please refer to [the user documentation](./USER_DOC.md)

# Setting up
## Environment
- A sample .env is provided in the `/srcs/` directory, while there are fallbacks in the scripts, it is best you have everything setup correctly.
- The `secrets` directory *MUST* contain the following files. The project will not run otherwise.
```
db_password.txt
db_root_password.txt
db_user.txt
ssl_subject.txt
```
- If you want to access localhost through `lucorrei.42.fr` as suggested in the eval you should add the line to the `/etc/hosts` file. You could do so, for example with `sudo vi /etc/hosts/`.

# Building and running
Ensure you have the docker daemon, docker CLI and docker compose installed and available in your PATH. Navigate to the root of the repo and run `make build` and `make start`. `make up` will do both for you.

# Useful commands
Check [Makefile](./Makefile) or run `make help` to see a list of available options. The most useful ones are `make restart SERVICE=<service>` and `make logs [SERVICE=<service>]`. Run the log command to a file or in a separate terminal, it runs with the -f flag.

# Persistence
Website data is stored inside /home/lucorrei/data/wordpress and DB data inside  /home/lucorrei/data/mariadb. They are docker volumes bound by the compose file, as required in the subject. Modify it as needed.
