# Guia de Estilo de Componentes

Este arquivo define regras visuais e de interação para componentes da interface do ShapeLog. Ele complementa `AGENTS.md` e `CLAUDE.md` e deve ser seguido sempre que houver criação ou ajuste de UI.

## Princípios

- priorizar clareza visual, baixo atrito e preenchimento rápido
- preferir componentes com aparência consistente entre navegadores
- evitar controles nativos do browser quando eles prejudicarem a estética ou a usabilidade
- manter comportamento previsível em mobile e desktop
- garantir que áreas clicáveis sejam generosas, especialmente em formulários

## Base visual obrigatória

- a interface web do ShapeLog deve ser `Flowbite-first`
- sempre preferir componentes e anatomias compatíveis com Flowbite para:
  - cards
  - botões
  - alerts
  - navegação
  - inputs
  - estados vazios
- partials Rails compartilhados são permitidos e desejáveis, desde que funcionem como wrappers finos sobre o padrão visual do Flowbite
- `Stimulus` pode continuar sendo usado para comportamentos específicos do produto quando o Flowbite não cobre a interação sozinho
- evitar criar uma segunda linguagem visual paralela com componentes ad hoc por tela

## Inputs de data

- para contexto pt-BR, a representação visual de data deve ser `dd/mm/aaaa`
- evitar `input[type="date"]` quando o browser exibir formato inconsistente com pt-BR
- preferir campo de texto com placeholder claro e parsing no servidor quando necessário
- labels e mensagens de ajuda devem reforçar o formato esperado

## Inputs numéricos

- evitar `input[type="number"]` em formulários principais quando o spinner nativo deixar a interface visualmente ruim
- para peso, doses e medidas semelhantes, preferir `input[type="text"]` com `inputmode="decimal"`
- aceitar vírgula como separador decimal na interface
- manter unidade visível no próprio campo quando isso reduzir ambiguidade, como `kg` e `cm`

## Booleanos e toggles

- não usar checkbox ou radio pequeno como affordance principal em cards clicáveis
- para campos booleanos, preferir switch deslizante com trilho e knob visual
- o container inteiro do componente deve ser clicável
- o estado ligado/desligado precisa ficar evidente por posição, cor e contraste
- o input real pode ficar visualmente escondido, mas deve continuar semanticamente presente para acessibilidade e submissão do formulário

## Radios e seleções exclusivas

- quando houver escolha única entre opções, evitar radios nativos isolados se o clique principal estiver no container
- usar cards ou pills clicáveis ligados corretamente ao `input`
- o componente deve deixar claro qual opção está selecionada sem depender de precisão no clique

## Formulários

- manter labels sempre visíveis
- placeholders ajudam, mas não substituem label
- campos principais devem ter altura confortável para toque em mobile
- mensagens de erro devem aparecer próximas ao campo
- usar sticky actions em mobile quando isso reduzir atrito de envio

## Consistência visual

- borda, raio, espaçamento e estados de foco devem seguir o padrão visual já existente no projeto
- evitar misturar componentes com comportamento nativo do browser e componentes altamente customizados no mesmo formulário, quando isso gerar inconsistência perceptível
- se um componente customizado for introduzido, reutilizar o mesmo padrão nas telas equivalentes
- evitar hex codes e variantes visuais hardcoded diretamente nas views quando houver wrapper compartilhado para o caso
