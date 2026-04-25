COMPOSE := docker compose -f infra/docker-compose.yml

.PHONY: help build setup up down restart shell console logs db-migrate db-seed db-reset test

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
