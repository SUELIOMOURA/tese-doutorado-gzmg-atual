############################################################
# TESE - APLICAÇÃO EMPÍRICA COM A BASE NMES1988
# Autor: Suélio Alves de Moura
# Objetivo: Exploração, diagnóstico e comparação inicial
#           de modelos de contagem na base NMES1988
############################################################

# ==========================================================
# 1) Instalação e carregamento dos pacotes
# ==========================================================

# Instale apenas se necessário
install.packages(c("AER", "MASS", "pscl", "lmtest", "sandwich", "ggplot2", "dplyr"))

library(AER)       # base NMES1988 + dispersiontest()
library(MASS)      # glm.nb()
library(pscl)      # hurdle() e zeroinfl()
library(lmtest)    # coeftest(), lrtest(), vuong()
library(sandwich)  # matriz robusta
library(ggplot2)   # gráficos
library(dplyr)     # manipulação

# ==========================================================
# 2) Carregamento da base
# ==========================================================

data("NMES1988", package = "AER")

# Visualizar estrutura geral
str(NMES1988)
dim(NMES1988)
names(NMES1988)

# Resumo geral
summary(NMES1988)

# ==========================================================
# 3) Seleção do subconjunto sugerido na literatura do pacote
#    visits, health, chronic, gender, school, insurance
# ==========================================================

nmes <- NMES1988[, c("visits", "health", "chronic", "gender", "school", "insurance")]

# Verificar estrutura do subconjunto
str(nmes)
summary(nmes)

# Remover possíveis faltantes, se existirem
nmes <- na.omit(nmes)

# ==========================================================
# 4) Estatísticas descritivas da variável resposta
# ==========================================================

# Média e variância
media_visits <- mean(nmes$visits)
variancia_visits <- var(nmes$visits)

# Proporção de zeros
prop_zeros <- mean(nmes$visits == 0)

# Frequência absoluta dos valores de visits
freq_visits <- table(nmes$visits)

cat("Número de observações:", nrow(nmes), "\n")
cat("Média de visits:", media_visits, "\n")
cat("Variância de visits:", variancia_visits, "\n")
cat("Razão variância/média:", variancia_visits / media_visits, "\n")
cat("Proporção de zeros:", prop_zeros, "\n")

# ==========================================================
# 5) Tabela resumo para possível uso na tese
# ==========================================================

resumo_y <- data.frame(
  n = nrow(nmes),
  media = media_visits,
  variancia = variancia_visits,
  razao_var_media = variancia_visits / media_visits,
  proporcao_zeros = prop_zeros,
  min = min(nmes$visits),
  q1 = quantile(nmes$visits, 0.25),
  mediana = median(nmes$visits),
  q3 = quantile(nmes$visits, 0.75),
  max = max(nmes$visits)
)

print(resumo_y)

# ==========================================================
# 6) Gráficos exploratórios da variável resposta
# ==========================================================

# Histograma discreto
ggplot(nmes, aes(x = visits)) +
  geom_histogram(binwidth = 1, boundary = -0.5, closed = "right") +
  labs(
    title = "Distribuição da variável visits",
    x = "Número de visitas médicas",
    y = "Frequência"
  )

# Gráfico de barras da distribuição empírica
ggplot(as.data.frame(freq_visits), aes(x = as.numeric(Var1), y = Freq)) +
  geom_col() +
  labs(
    title = "Distribuição empírica de visits",
    x = "Número de visitas médicas",
    y = "Frequência"
  )

# ==========================================================
# 7) Gráficos exploratórios com covariáveis
# ==========================================================

# Boxplot por estado de saúde percebido
ggplot(nmes, aes(x = health, y = log(visits + 0.5))) +
  geom_boxplot() +
  labs(
    title = "log(visits + 0.5) por estado de saúde",
    x = "Saúde percebida",
    y = "log(visits + 0.5)"
  )

# Boxplot por sexo
ggplot(nmes, aes(x = gender, y = log(visits + 0.5))) +
  geom_boxplot() +
  labs(
    title = "log(visits + 0.5) por sexo",
    x = "Sexo",
    y = "log(visits + 0.5)"
  )

# Boxplot por seguro privado
ggplot(nmes, aes(x = insurance, y = log(visits + 0.5))) +
  geom_boxplot() +
  labs(
    title = "log(visits + 0.5) por seguro privado",
    x = "Seguro privado",
    y = "log(visits + 0.5)"
  )

# Relação com número de doenças crônicas
ggplot(nmes, aes(x = chronic, y = visits)) +
  geom_jitter(height = 0.1, width = 0.1, alpha = 0.3) +
  labs(
    title = "Visits versus número de condições crônicas",
    x = "Número de condições crônicas",
    y = "Número de visitas médicas"
  )

# Relação com anos de estudo
ggplot(nmes, aes(x = school, y = visits)) +
  geom_jitter(height = 0.1, width = 0.1, alpha = 0.3) +
  labs(
    title = "Visits versus anos de estudo",
    x = "Anos de estudo",
    y = "Número de visitas médicas"
  )

# ==========================================================
# 8) Ajuste do modelo de Poisson
# ==========================================================

mod_pois <- glm(
  visits ~ health + chronic + gender + school + insurance,
  data = nmes,
  family = poisson(link = "log")
)

summary(mod_pois)

# Erros-padrão robustos
coeftest(mod_pois, vcov = sandwich)

# ==========================================================
# 9) Teste de dispersão
#    Se rejeitar equidispersão, Poisson fica inadequado
# ==========================================================

dispersiontest(mod_pois)
dispersiontest(mod_pois, trafo = 2)

# ==========================================================
# 10) Ajuste do modelo Binomial Negativa
# ==========================================================

mod_nb <- glm.nb(
  visits ~ health + chronic + gender + school + insurance,
  data = nmes
)

summary(mod_nb)

# Comparação Poisson vs NB
AIC(mod_pois, mod_nb)
BIC(mod_pois, mod_nb)
lrtest(mod_pois, mod_nb)

# ==========================================================
# 11) Ajuste de modelos com zeros em excesso
# ==========================================================

# Modelo hurdle binomial negativa
mod_hurdle_nb <- hurdle(
  visits ~ health + chronic + gender + school + insurance |
    chronic + gender + school + insurance,
  data = nmes,
  dist = "negbin"
)

summary(mod_hurdle_nb)

# Modelo zero-inflated binomial negativa
mod_zinb <- zeroinfl(
  visits ~ health + chronic + gender + school + insurance |
    chronic + gender + school + insurance,
  data = nmes,
  dist = "negbin"
)

summary(mod_zinb)

# ==========================================================
# 12) Comparação entre modelos
# ==========================================================

AIC(mod_pois, mod_nb, mod_hurdle_nb, mod_zinb)
BIC(mod_pois, mod_nb, mod_hurdle_nb, mod_zinb)

# Comparação não aninhada entre hurdle e ZINB
vuong(mod_hurdle_nb, mod_zinb)

# ==========================================================
# 13) Valores ajustados e zeros observados vs esperados
# ==========================================================

# Função auxiliar para proporção esperada de zeros
prop_zero_poisson <- mean(dpois(0, lambda = fitted(mod_pois)))

# Para NB:
# probabilidade de zero para cada observação usando parâmetros ajustados
mu_nb <- fitted(mod_nb)
theta_nb <- mod_nb$theta
prop_zero_nb <- mean((theta_nb / (theta_nb + mu_nb))^theta_nb)

prop_zero_obs <- mean(nmes$visits == 0)

cat("Proporção observada de zeros:", prop_zero_obs, "\n")
cat("Proporção esperada de zeros - Poisson:", prop_zero_poisson, "\n")
cat("Proporção esperada de zeros - NB:", prop_zero_nb, "\n")

# ==========================================================
# 14) Tabela comparativa final
# ==========================================================

comparacao_modelos <- data.frame(
  Modelo = c("Poisson", "Binomial Negativa", "Hurdle NB", "ZINB"),
  AIC = c(AIC(mod_pois), AIC(mod_nb), AIC(mod_hurdle_nb), AIC(mod_zinb)),
  BIC = c(BIC(mod_pois), BIC(mod_nb), BIC(mod_hurdle_nb), BIC(mod_zinb)),
  LogLik = c(logLik(mod_pois), logLik(mod_nb), logLik(mod_hurdle_nb), logLik(mod_zinb))
)

print(comparacao_modelos)

# ==========================================================
# 15) Exportar resultados
# ==========================================================

write.csv(resumo_y, "resumo_variavel_visits_NMES1988.csv", row.names = FALSE)
write.csv(comparacao_modelos, "comparacao_modelos_NMES1988.csv", row.names = FALSE)

# ==========================================================
# 16) Objeto final para sua tese
#     Aqui ficará fácil substituir pelo seu próprio modelo
# ==========================================================

# Exemplo de fórmula-base:
formula_base <- visits ~ health + chronic + gender + school + insurance

# Você poderá usar:
# - nmes$visits como variável resposta
# - as covariáveis acima como estrutura explicativa
# - comparar seu modelo com Poisson, NB, hurdle e ZINB