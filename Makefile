.PHONY: help


help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

start-bedrock: umount mount ## Start wp server on bedrock
	@wp server --docroot=$(shell pwd)/bedrock/web --host=0.0.0.0

start-sage: ## Start sage yarn sync proxy to bedrock
	@cd sage && yarn start

build-sage: ## Build sage assets
	@cd sage && yarn build:production

up: mount up-compose ## Mount sage to bedrock and start development environemnt

up-compose: ## Start docker-compose stack
	docker-compose -f docker-compose.yml up -d $(arg)

down: down-compose umount ## Take down the entire docker-compose stack and umount sage
down-compose: ## Take down the entire docker-compose stack
	docker-compose -f docker-compose.yml down

destroy: ## Take down a service from docker-compose
	docker-compose -f docker-compose.yml down -v $(arg)

start: ## Start a specific service from docker-compose
	docker-compose -f docker-compose.yml start $(arg)

stop: ## Stop a specific service from docker-compose
	docker-compose -f docker-compose.yml stop $(arg)

kill: ## Force-stop a specific service from docker-compose
	docker-compose -f docker-compose.yml kill $(arg)

restart: ## Restart docker-compose stack
	docker-compose -f docker-compose.yml stop $(arg)
	docker-compose -f docker-compose.yml up -d --no-deps $(arg)

build: ## Build command for docker-compose
	docker-compose -f docker-compose.yml build $(arg)

logs: ## Show logs from docker-compose stack or service
	docker-compose -f docker-compose.yml logs --tail=100 -f $(arg)

ps: ## List processes
	docker-compose -f docker-compose.yml ps $(arg)

run-sage: ## docker-compose run command for sage
	docker-compose -f docker-compose.yml run --rm --no-deps sage $(arg)

run-bedrock: ## docker-compose run command for bedrock
	docker-compose -f docker-compose.yml run --rm --no-deps bedrock $(arg)

exec-sage: ## docker-compose exec for sage
	docker-compose -f docker-compose.yml exec sage $(arg)

exec-bedrock: ## docker-compose exec for bedrock
	docker-compose -f docker-compose.yml exec bedrock $(arg)

sage-vendor-install: ## Install composer dependencies for sage
	docker-compose -f docker-compose.yml exec bedrock bash -c 'cd web/app/themes/sage/ && composer install'

db-shell: ## Login to db shell using docker-compose exec command
	docker-compose -f docker-compose.yml exec db bash -l

mount: umount-sage mount-sage ## Mount sage to bedrock
mount-sage: ## Mount sage to bedrock
	@mkdir -p $(shell pwd)/bedrock/web/app/themes/sage
	@sudo bindfs -o force-user=80 -o force-group=80 -o create-for-user=80 -o create-for-group=80 -o perms=0755 $(shell pwd)/sage $(shell pwd)/bedrock/web/app/themes/sage
	@echo "[INFO] Mounting sage successfully. Sage is available at $(shell pwd)/bedrock/web/app/themes/sage"

umount: umount-sage ## Unmount sage
umount-sage: ## Unmount sage
	@if mount | grep $(shell pwd)/bedrock/web/app/themes/sage > /dev/null; then \
		echo "[INFO] Detect mounted sage directory"; \
		echo "[INFO] Proceeding to umount sage"; \
		sudo umount $(shell pwd)/bedrock/web/app/themes/sage; \
	elif [ -d "$(shell pwd)/bedrock/web/app/themes/sage" ]; then \
		sudo rm -rf $(shell pwd)/bedrock/web/app/themes/sage; \
	else \
		echo "[INFO] sage is NOT mounted"; \
	fi
	@echo "[INFO] Un-mounting sage directory completed!"
