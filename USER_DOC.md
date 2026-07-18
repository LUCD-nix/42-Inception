*This document assumes the Docker Project is already built and instantiated on your machine. If that is not the case, please refer to [the development guide](./DEV_DOC.md)*

# Provided services
This project provides a Wordpress blog that depends on 3 different services:
- A database (MariaDB).
- The Wordpress server.
- NGINX as the web server.

# Starting and stopping
`cd` into the root of the project and run `make start` or `make stop`. If there is an error you can inspect it with `make logs`

# Managing the website
- Open a web browser and enter `localhost` in the navbar, the project uses self-signed certificates so when you see an error click `Advanced options` and `Proceed anyway` to access the blog.
- Sign-in with your admin credentials!

# Credentials
Your credentials are all located inside the `secrets` directory at the root of the project. **DO NOT** move them out of that folder, copy them, or otherwise show them to anybody.

# Check services
- If the website seems to be malfunctioning run `make ps` and check that you see all 3 services running (nginx, mariadb, and wordpress). If not try restarting the missing one with `make restart SERVICE=<service>`
