COMPOSE_FILE := srcs/docker-compose.yml
ENV_FILE := srcs/.env
COMPOSE := docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)

ifneq (,$(wildcard $(ENV_FILE)))
include $(ENV_FILE)
export
endif

SERVICE ?=

.PHONY: all build up run down stop start restart logs ps config pull mkdir-data clean fclean re reset-data help

all: up

build: mkdir-data
	$(COMPOSE) build

up run: mkdir-data
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop $(SERVICE)

start:
	$(COMPOSE) start $(SERVICE)

restart:
	@if [ -z "$(SERVICE)" ]; then \
		echo "Usage: make restart SERVICE=<service>"; \
		exit 1; \
	fi
	$(COMPOSE) restart $(SERVICE)

logs:
	$(COMPOSE) logs -f $(SERVICE)

ps:
	$(COMPOSE) ps

config:
	$(COMPOSE) config

pull:
	$(COMPOSE) pull

mkdir-data:
	mkdir -p $(MARIADB_DATA_PATH) $(WORDPRESS_DATA_PATH)

clean: down
	$(COMPOSE) rm -fsv

fclean: down
	$(COMPOSE) down -v --rmi local --remove-orphans

reset-data: fclean
	@if [ "$(CONFIRM)" != "YES" ]; then \
		echo "This deletes bind-mounted database and WordPress data."; \
		echo "Run: make reset-data CONFIRM=YES"; \
		exit 1; \
	fi
	rm -rf $(MARIADB_DATA_PATH) $(WORDPRESS_DATA_PATH)
	$(MAKE) mkdir-data

re: fclean up

help:
	@echo "Available targets:"
	@echo "  make build                 Build images"
	@echo "  make up | make run          Build and start containers detached"
	@echo "  make down                  Stop and remove containers/network"
	@echo "  make restart SERVICE=name  Restart one service, e.g. SERVICE=nginx"
	@echo "  make logs [SERVICE=name]   Follow logs"
	@echo "  make ps                    Show containers"
	@echo "  make config                Render compose config"
	@echo "  make clean                 Down and remove stopped service containers"
	@echo "  make fclean                Down, remove compose volumes and local images"
	@echo "  make reset-data CONFIRM=YES Delete bind-mounted data directories"
	@echo "  make re                    fclean then up"
