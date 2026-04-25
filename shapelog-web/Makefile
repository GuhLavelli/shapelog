.PHONY: help bootstrap build setup up down restart shell console logs db-migrate db-seed test

help: ## Exibe esta ajuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ── Bootstrap (rodar apenas uma vez) ────────────────────────────────────────

bootstrap: ## Cria o app Rails dentro do container (rodar SOMENTE uma vez)
	docker compose build
	docker compose run --rm web rails new . --force --no-deps \
		-d postgresql \
		-c tailwind \
		--skip-active-storage \
		--skip-action-mailbox \
		--skip-action-text \
		--skip-jbuilder \
		--skip-docker
	docker compose build

setup: ## Instala gems, cria banco, roda migrations e seeds
	docker compose run --rm web bundle install
	docker compose run --rm web rails db:create db:migrate db:seed

# ── Ciclo de vida ────────────────────────────────────────────────────────────

build: ## Reconstrói a imagem Docker
	docker compose build

up: ## Sobe todos os serviços
	docker compose up

down: ## Para e remove os containers
	docker compose down

restart: ## Reinicia o serviço web
	docker compose restart web

# ── Desenvolvimento ──────────────────────────────────────────────────────────

shell: ## Abre shell bash no container web
	docker compose run --rm web bash

console: ## Abre o Rails console
	docker compose run --rm web rails console

logs: ## Acompanha os logs do serviço web
	docker compose logs -f web

# ── Banco de dados ───────────────────────────────────────────────────────────

db-migrate: ## Roda as migrations pendentes
	docker compose run --rm web rails db:migrate

db-seed: ## Executa os seeds
	docker compose run --rm web rails db:seed

db-reset: ## Dropa, recria e popula o banco
	docker compose run --rm web rails db:drop db:create db:migrate db:seed

# ── Testes ───────────────────────────────────────────────────────────────────

test: ## Roda a suite de testes
	docker compose run --rm -e RAILS_ENV=test web rails test
