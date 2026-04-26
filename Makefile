COMPOSE := docker compose -f infra/docker-compose.yml
COMPOSE_PROD := docker compose --env-file infra/production.env -f infra/docker-compose.prod.yml

.PHONY: help build setup up down restart shell console logs db-migrate db-seed db-reset test prod-config prod-build prod-up prod-down prod-restart prod-logs prod-migrate prod-console prod-backup

help: ## Exibe esta ajuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Instala gems, cria banco, roda migrations e seeds
	$(COMPOSE) run --rm web bundle install
	$(COMPOSE) run --rm web rails db:create db:migrate db:seed

# ── Ciclo de vida ────────────────────────────────────────────────────────────

build: ## Reconstrói a imagem Docker
	$(COMPOSE) build

up: ## Sobe todos os serviços
	$(COMPOSE) up

down: ## Para e remove os containers
	$(COMPOSE) down

restart: ## Reinicia o serviço web
	$(COMPOSE) restart web

# ── Desenvolvimento ──────────────────────────────────────────────────────────

shell: ## Abre shell bash no container web
	$(COMPOSE) run --rm web bash

console: ## Abre o Rails console
	$(COMPOSE) run --rm web rails console

logs: ## Acompanha os logs do serviço web
	$(COMPOSE) logs -f web

# ── Banco de dados ───────────────────────────────────────────────────────────

db-migrate: ## Roda as migrations pendentes
	$(COMPOSE) run --rm web rails db:migrate

db-seed: ## Executa os seeds
	$(COMPOSE) run --rm web rails db:seed

db-reset: ## Dropa, recria e popula o banco
	$(COMPOSE) run --rm web rails db:drop db:create db:migrate db:seed

# ── Testes ───────────────────────────────────────────────────────────────────

test: ## Roda a suite de testes
	$(COMPOSE) run --rm -e RAILS_ENV=test web rails test

# ── Produção ────────────────────────────────────────────────────────────────

prod-config: ## Valida a configuração Docker Compose de produção
	$(COMPOSE_PROD) config

prod-build: ## Constrói a imagem de produção
	$(COMPOSE_PROD) build

prod-up: ## Sobe os serviços de produção em background
	$(COMPOSE_PROD) up -d

prod-down: ## Para e remove os containers de produção
	$(COMPOSE_PROD) down

prod-restart: ## Reinicia o serviço web de produção
	$(COMPOSE_PROD) restart web

prod-logs: ## Acompanha logs da aplicação em produção
	$(COMPOSE_PROD) logs -f web

prod-migrate: ## Executa migrations em produção
	$(COMPOSE_PROD) run --rm web bin/rails db:migrate

prod-console: ## Abre o Rails console em produção
	$(COMPOSE_PROD) run --rm web bin/rails console

prod-backup: ## Cria backup gzip do PostgreSQL de produção
	infra/scripts/backup-postgres.sh
