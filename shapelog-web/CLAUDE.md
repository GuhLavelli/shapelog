# Contexto Base do Projeto — Tracker de Evolução do Emagrecimento (MVP)

## Papel esperado

Atue como um **engenheiro de software sênior, pragmático, organizado e muito experiente**, com foco em:

- construir uma base sólida sem overengineering
- priorizar velocidade de entrega do MVP
- seguir convenções idiomáticas do Ruby on Rails
- escrever código limpo, legível e fácil de evoluir
- tomar decisões simples, consistentes e bem justificadas
- evitar complexidade desnecessária

A prioridade deste projeto é **ter um MVP funcional, bonito, simples de manter e agradável de usar**, ao mesmo tempo em que serve como oportunidade prática de aprendizado em **Ruby on Rails**.

---

## Objetivo do produto

Construir um **web app pessoal e privado** para acompanhar a evolução do emagrecimento, com foco em:

- evolução de peso
- consistência em treino/cardio
- uso de Mounjaro
- percepção corporal
- medidas corporais
- visualização simples da jornada

O sistema deve responder rapidamente perguntas como:

- Estou evoluindo?
- Meu peso está realmente caindo?
- Estou consistente?
- Como meu corpo está reagindo ao longo do tempo?
- Como estão treino, cardio, fome, energia e aplicações?

---

## Decisões de stack já definidas

## Stack principal obrigatória

- **Ruby on Rails**
- **PostgreSQL**
- **Hotwire / Turbo**
- **Tailwind CSS**

## Itens complementares permitidos

- **Stimulus** apenas quando necessário para interações simples
- **Active Storage** para fotos em uma fase futura
- Biblioteca de gráfico simples, apenas se realmente necessária no MVP

---

## Diretriz principal de arquitetura

Este projeto deve ser desenvolvido como um **monólito Rails tradicional**.

### Isso significa:

- não separar frontend e backend neste momento
- não criar API separada agora
- não usar React no MVP
- não usar microserviços
- não criar arquitetura excessivamente abstrata
- não criar camadas desnecessárias antes da hora

A base deve aproveitar o que Rails já oferece muito bem:

- MVC
- Active Record
- migrations
- validations
- partials
- Turbo
- helpers
- generators
- convenções do framework

---

## Objetivos técnicos do MVP

O projeto deve priorizar:

- rapidez de desenvolvimento
- simplicidade de manutenção
- experiência moderna sem SPA
- boa organização de domínio
- código idiomático em Rails
- facilidade de expansão futura

---

## Regras de implementação

## 1. Seguir convenções do Rails

Prefira sempre o caminho idiomático do framework.

- use generators quando fizer sentido
- use RESTful routes
- use models enxutos, mas coerentes
- use controllers objetivos
- use views simples e organizadas
- use partials para reaproveitamento
- use Turbo para melhorar UX sem complexidade de frontend

Evite reinventar padrões que o Rails já resolve bem.

---

## 2. Evitar overengineering

Não criar antes do tempo:

- service objects para tudo
- presenters complexos sem necessidade
- form objects desnecessários
- múltiplas camadas abstratas
- CQRS
- event bus
- arquitetura enterprise sem necessidade real

Service objects só devem ser usados quando houver **regra de negócio realmente complexa** ou fluxo que claramente mereça extração.

---

## 3. Manter o MVP pequeno

Foco em entregar primeiro o essencial.

Tudo o que não for central para validar o produto deve ser adiado.

---

## 4. UX simples e agradável

A interface deve ser:

- limpa
- responsiva
- rápida
- fácil de preencher no dia a dia
- agradável visualmente
- orientada a pouco atrito

O app precisa ser pensado como algo de uso recorrente, então registrar informações diárias deve ser rápido.

---

## 5. Mobile-first sem prejudicar desktop

A aplicação deve funcionar bem em desktop, mas a mentalidade de construção deve priorizar:

- telas simples
- boa responsividade
- formulário fácil no celular
- dashboard claro em telas menores

---

## 6. Código limpo e previsível

Priorizar:

- nomes claros
- baixo acoplamento
- baixa complexidade
- arquivos organizados
- consistência de estilo

Evitar:

- controllers gigantes
- models confusos
- callbacks excessivos
- lógica pesada em view
- duplicação evitável

---

## Escopo funcional do MVP

## Funcionalidades obrigatórias da primeira versão

### 1. Dashboard

Tela inicial com visão resumida da jornada.

#### Exibir:
- peso atual
- diferença desde o peso inicial
- diferença nos últimos 7 dias
- média móvel de 7 dias
- quantidade de semanas em acompanhamento
- último treino
- streak de treino
- última aplicação de Mounjaro

---

### 2. Check-in diário

Principal interação do sistema.

#### Campos:
- `date`
- `weight`
- `trained` (boolean)
- `cardio` (boolean)
- `steps` (opcional)
- `hunger_level` (1 a 10)
- `energy_level` (1 a 10)
- `calories_estimate` (opcional)
- `waist` (opcional)
- `notes` (texto livre)

#### Regras:
- apenas 1 check-in por dia por usuário
- edição permitida
- experiência de preenchimento rápida

---

### 3. Controle de aplicação de Mounjaro

#### Campos:
- `application_date`
- `dose`
- `application_site` (opcional)
- `side_effects` (texto)
- `notes`

#### Objetivo:
Permitir relacionar aplicação com:
- fome
- energia
- evolução de peso
- percepção corporal

---

### 4. Evolução de peso

#### Funcionalidades:
- histórico de peso
- gráfico simples
- média móvel de 7 dias
- perda total
- ritmo semanal
- meta de peso

A média móvel é importante para reduzir interpretação errada de oscilações diárias.

---

### 5. Consistência de treino/cardio

#### Métricas:
- dias treinados na semana
- dias com cardio
- frequência mensal
- streak atual

---

### 6. Medidas corporais

#### Campos:
- `date`
- `waist`
- `chest`
- `arm`
- `thigh`
- `notes`

---

## Itens que devem ficar fora do MVP inicial

Não implementar agora:

- app mobile nativo
- API pública
- integração com wearables
- notificações complexas
- permissões avançadas
- multiusuário complexo
- IA
- dashboards altamente analíticos
- automações externas
- fotos de progresso no primeiro momento, se atrasarem o MVP

---

## Modelagem inicial sugerida

## Entidades principais

### `User`
Responsável por autenticação e propriedade dos dados.

### `DailyCheckin`
Registro diário do acompanhamento.

### `MounjaroApplication`
Controle de aplicações.

### `BodyMeasurement`
Registro de medidas corporais.

### `Goal`
Informações de meta do usuário.

---

## Estrutura conceitual das relações

- `User has_many :daily_checkins`
- `User has_many :mounjaro_applications`
- `User has_many :body_measurements`
- `User has_one :goal`

---

## Estrutura inicial das páginas

### 1. Dashboard
Resumo geral do progresso.

### 2. Check-ins
- listagem
- criação
- edição

### 3. Aplicações de Mounjaro
- listagem
- criação
- edição

### 4. Medidas corporais
- listagem
- criação
- edição

### 5. Meta
- visualização
- edição

---

## Diretrizes para modelagem e domínio

## DailyCheckin
Deve ser a entidade central do produto.

Ela representa o registro cotidiano do usuário.

Campos e regras devem ser pensados para permitir métricas posteriores sem complicar o MVP.

---

## Goal
Deve conter pelo menos:

- peso inicial
- peso alvo
- data inicial
- objetivo semanal, se fizer sentido

---

## Validações importantes

Implementar validações básicas e úteis, sem exagero.

Exemplos:

- `date` obrigatório
- `weight` obrigatório e positivo
- `hunger_level` entre 1 e 10
- `energy_level` entre 1 e 10
- unicidade de check-in por usuário/data
- medidas numéricas positivas quando informadas

---

## Estratégia de autenticação

Autenticação deve ser simples.

Como o app é pessoal, a implementação pode ser direta, sem fluxo complexo de permissões.

Objetivo:
- login funcional
- sessão estável
- acesso privado aos dados

Não criar sistema de roles ou permissões sofisticadas agora.

---

## Estrutura de pastas recomendada

```txt
app/
  controllers/
  models/
  views/
    dashboard/
    daily_checkins/
    mounjaro_applications/
    body_measurements/
    goals/
    shared/
  helpers/
  javascript/
  assets/
config/
db/
  migrate/