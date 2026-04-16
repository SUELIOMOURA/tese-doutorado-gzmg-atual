# tese-doutorado-gzmg-atual
Scripts em R criados durante a minha tese, 2026

Scripts em **R** desenvolvidos no contexto da minha tese de doutorado, com foco em **gráficos de controle para dados de contagem** sob **inflação/deflação de zeros** e diferentes regimes de dispersão.

## Objetivo

Este repositório reúne os códigos utilizados na etapa aplicada da tese, incluindo a construção e comparação de gráficos de controle baseados nos modelos:

- **GZMG-u**
- **ZIP**
- **Poisson**
- **Geométrico**
- **COM-Poisson**

A aplicação empírica foi realizada com dados reais da base **NMES1988**, amplamente utilizada na literatura de modelagem para dados de contagem. A variável resposta analisada foi **`visits`**, correspondente ao número de visitas médicas realizadas por indivíduos idosos. Essa variável apresenta natureza discreta, forte presença de zeros e acentuada sobredispersão, características compatíveis com o escopo metodológico da tese. :contentReference[oaicite:1]{index=1}

## Descrição da aplicação

Na análise exploratória inicial da variável `visits`, observou-se:

- média amostral igual a **5.77**;
- variância igual a **45.68**;
- razão variância/média de aproximadamente **7.91**;
- proporção observada de zeros igual a **0.15**.

Esses resultados evidenciam **forte sobredispersão** e **excesso de zeros**, indicando inadequação de modelos mais restritivos, como o modelo de Poisson, para fins de monitoramento estatístico do processo. :contentReference[oaicite:2]{index=2}

Para construção dos gráficos na escala dos totais, as observações individuais foram reorganizadas em **subgrupos de tamanho fixo `n = 100`**, gerando **44 subgrupos completos**. Desses:

- os **20 primeiros subgrupos** foram utilizados na **Fase 1**, para estimação dos parâmetros e construção dos limites de controle;
- os **24 subgrupos restantes** compuseram a **Fase 2**, destinada ao monitoramento do processo. :contentReference[oaicite:3]{index=3}

## Principais resultados

A comparação entre os modelos mostrou que:

- o gráfico de **Poisson** produziu os limites mais estreitos;
- o gráfico **GZMG-u** apresentou os limites mais amplos;
- os gráficos **ZIP** e **COM-Poisson** resultaram em limites coincidentes;
- o gráfico **Geométrico** apresentou comportamento intermediário. :contentReference[oaicite:4]{index=4}

Na aplicação com dados reais, o gráfico de **Poisson** foi o mais sensível e sinalizou maior número de pontos fora de controle, comportamento associado à inadequação do modelo diante da sobredispersão observada. Em contraste, o gráfico **GZMG-u** apresentou monitoramento mais estável, com menor incidência de alarmes espúrios e melhor aderência à variabilidade empírica dos dados. :contentReference[oaicite:5]{index=5}

De modo geral, os resultados empíricos reforçam a principal conclusão da tese: **a escolha do modelo probabilístico subjacente ao gráfico de controle influencia decisivamente o desempenho do monitoramento**, e o gráfico **GZMG-u** mostrou-se uma alternativa mais flexível, consistente e robusta em cenários com sobredispersão e comportamento anômalo dos zeros. :contentReference[oaicite:6]{index=6}

## Estrutura do repositório

A organização dos arquivos pode incluir, por exemplo:

```text
.
├── R/
├── dados/
├── figuras/
├── resultados/
└── README.md

