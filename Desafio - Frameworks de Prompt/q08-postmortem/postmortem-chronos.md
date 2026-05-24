# Postmortem técnico — Incidente Chronos API (v2.48.0)

| Campo | Valor |
|-------|--------|
| **Data** | 2026-04-24 |
| **Serviço** | Chronos API |
| **Severidade** | Critical (em andamento) |
| **Versão suspeita** | v2.48.0 (deploy 2026-04-23 18:42 UTC) |
| **Decisão solicitada** | Rollback vs. scaling emergencial |
| **Audience** | Doc Brown (CTO) |

---

## 1. Resumo executivo

Durante pico de tráfego (~14:00–14:20 UTC), o Chronos entrou em degradação severa: **p99 de 420 ms → 8.100 ms**, **error rate de 0,2% → 11,7%**. Logs apontam **esgotamento do pool de conexões Ledger** (20/pod, 147 aguardando), **timeouts de 2 s** no novo cliente, falhas no endpoint **`POST /v2/transactions/batch`** (novo em v2.48.0), **circuit breaker aberto** e **backlog de 50k mensagens** no Reactor (lag 18 min).

O RDS está em **240/250 conexões** (96% do limite) com **12 pods** no HPA máximo — padrão consistente com **12 × pool max 20 = 240 conexões**, saturando o Ledger.

**Recomendação:** **Rollback imediato para v2.47.0** (Opção A). Scaling isolado (Opção B) alivia teto do RDS mas **não reverte** timeout agressivo, novo pool/biblioteca e carga do batch endpoint que disparou a cascata.

---

## 2. Impacto observado

| Dimensão | Antes (13:30) | Pico (14:20) |
|----------|---------------|--------------|
| p99 latency | 420 ms | **8.100 ms** |
| Request rate | 1.200/s | **2.650/s** |
| Error rate | 0,2% | **11,7%** |
| Pods Chronos | — | **12/12** (HPA max) |
| Conexões RDS | — | **240/250** |
| Reactor lag | — | **18 min** (↑ ~800 msg/min) |

**Blast radius:** Chronos → Ledger (saturation) → Reactor (publish failures) → fila `chronos-transactions` acumulando.

---

## 3. Linha do tempo

| Horário (UTC) | Evento |
|---------------|--------|
| 2026-04-23 18:42 | Deploy **v2.48.0** via Argo CD (batch endpoint, novo ledger-client, timeout 5s→2s) |
| 2026-04-24 13:30 | Métricas estáveis; error rate baseline 0,2% |
| 2026-04-24 14:00 | p99 780 ms, req rate 1.780/s — início de degradação |
| 2026-04-24 14:10 | p99 2.400 ms, error rate **4,5%** |
| 2026-04-24 14:15 | p99 5.200 ms, error rate **8,2%** |
| 2026-04-24 14:19:48 | Pool Ledger exhausted (20/20, **147 waiting**) |
| 2026-04-24 14:19:49 | Timeout 2000 ms + falha **`/v2/transactions/batch`** |
| 2026-04-24 14:19:51 | Circuit breaker Ledger **OPEN** (87%) |
| 2026-04-24 14:19:52 | Reactor publish failure (upstream error) |
| 2026-04-24 14:20 | p99 **8.100 ms**, error rate **11,7%** |

**Correlação:** degradação escala com tráfego após deploy com mudanças no caminho crítico Ledger + novo endpoint batch.

---

## 4. Causa raiz (provável)

**Primary:** Deploy **v2.48.0** introduziu carga e comportamento no cliente Ledger incompatíveis com o limite de conexões RDS sob pico + HPA max:

1. **`POST /v2/transactions/batch`** — aumenta concorrência e duração de queries no Ledger.
2. **Pool max=20/pod × 12 pods = 240 conexões** — esgota RDS (250 max, **240 observadas**).
3. **Timeout 5s → 2s** — amplifica falhas, retries e fila `waiting=147` sem liberar conexões a tempo.
4. **Refactor ledger-client + psycopg 3.2.0** — possível regressão de gestão de pool (contribuinte; confirmar em follow-up).

**Mecanismo da cascata:** pool exhausted → timeouts → batch failures → circuit breaker OPEN → Reactor não publica → backlog 50k+.

---

## 5. Fatores contribuintes

| Fator | Evidência |
|-------|-----------|
| HPA no máximo (12 pods) | Multiplica conexões ao Ledger linearmente |
| RDS quase no limite (96%) | Pouca margem antes de hard failure |
| Pico de tráfego (+120% req rate) | Expõe mudanças de v2.48.0 |
| Timeout reduzido | Falhas mais rápidas, menos throughput efetivo |
| Novo endpoint batch | Aparece explicitamente nos logs de erro |

CPU 62% e memória 71% indicam que **não é saturação de compute** — o gargalo é **dependência Ledger/conexões**.

---

## 6. Análise: Rollback vs. Scaling emergencial

| Critério | **A — Rollback v2.47.0** | **B — Scaling RDS + pool** |
|----------|--------------------------|----------------------------|
| **Tempo para efeito** | ~5–15 min (Argo CD) | 15–30+ min (RDS modify + redeploy config) |
| **Remove batch endpoint** | ✅ Sim | ❌ Não |
| **Restaura timeout 5s** | ✅ Sim | ❌ Não (config permanece) |
| **Revert client legado** | ✅ Sim | ❌ Não |
| **Aumenta teto RDS** | ❌ Não | ✅ Sim (margem conexões) |
| **Risco em pico** | Baixo (versão conhecida estável) | Médio (RDS resize em incidente; pool mal calibrado re-satura) |
| **Resolve Reactor backlog** | Parcial (para sangramento upstream) | Parcial |
| **Custo** | Baixo | Alto (RDS scale + operação) |

### Opção A — Rollback

**Prós:** Reversão comprovada; elimina batch endpoint e timeout agressivo; libera pressão no Ledger rapidamente; decisão reversível.

**Contras:** Perde features v2.48.0; backlog Reactor precisa drenar após estabilização.

### Opção B — Scaling emergencial

**Prós:** Aumenta margem de conexões RDS; pode combinar com bump de pool size.

**Contras:** **Não corrige** timeout 2s nem lógica do novo client; com 12 pods, pool 20/pod continua tendendo a saturar; resize RDS durante incidente é lento e arriscado; múltiplas variáveis mudando ao mesmo tempo dificultam diagnóstico.

---

## 7. Decisão recomendada

### ✅ **Opção A — Rollback imediato para v2.47.0**

**Fundamentação:**

1. Evidência temporal forte (deploy ontem → degradação no pico hoje).
2. Logs citam **`/v2/transactions/batch`** e **timeout 2000ms** — ambos introduzidos em v2.48.0.
3. Conexões 240/250 = assinatura de **pool × réplicas**, não apenas RDS pequeno.
4. Rollback é **mais rápido** e **menor risco** em war room de 20 min.
5. Scaling pode ser **follow-up planeado** após estabilização, com sizing correto de pool/replicas.

**Scaling (Opção B)** como ação **secundária** somente se, após rollback, conexões permanecerem > 80% com HPA < max — cenário **não observado** como root cause primário.

---

## 8. Ações imediatas (3)

1. **Executar rollback Argo CD** `chronos-api` → revisão **v2.47.0**; monitorar error rate e p99 nos próximos 10 min.
2. **Comunicar Reactor/on-call:** após Chronos estável, escalar consumers temporariamente para drenar lag (18 min → target < 5 min) — sem deploy adicional no Chronos.
3. **Congelar deploys** Chronos até postmortem completo; abrir ticket para revisar pool sizing (max conn/pod vs. RDS max vs. HPA max replicas).

---

## 9. Follow-ups pós-incidente

| Item | Owner sugerido | Prazo |
|------|----------------|-------|
| Load test isolado `POST /v2/transactions/batch` em staging | Engenharia | 1 semana |
| Fórmula: `pool_max × hpa_max ≤ rds_max_connections × 0.8` | SRE (Lorraine) | 3 dias |
| Revisar timeout Ledger (2s vs 5s) com SLO p99 | Doc Brown / Eng | 1 semana |
| Validar psycopg 3.2.0 + nova lib pool em canary antes de prod | Engenharia | Próximo release |
| Runbook Q07 — correlacionar memória vs. pool Ledger | SRE | Backlog |

---

## Apêndice — Evidências-chave

```
connection pool exhausted (max=20, active=20, waiting=147)
query timeout after 2000ms
POST /v2/transactions/batch failed
circuit-breaker ledger-client OPEN (87%)
Conexões Ledger: 240/250 | HPA: 12/12 pods
Reactor: 50.127 msgs, lag 18 min
```

---

*Documento gerado para decisão em war room — revisar após estabilização do incidente.*
