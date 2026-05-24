# Prompt — Q08 Postmortem Chronos

> **Status:** concluído  
> **Framework escolhido:** CARE

---

## [CONTEXT]

**Situação:** Incidente **em andamento** durante pico de tráfego. **Doc Brown (CTO)** precisa de um **postmortem técnico em 20 minutos** para decidir entre:

- **A)** Rollback do deploy **v2.48.0** (subiu ontem)
- **B)** Scaling emergencial (aumento de limits do **RDS** e do **pool de conexões**)

**Deploy v2.48.0** (2026-04-23 18:42:11 UTC):

```
Deploy chronos-api: v2.47.0 -> v2.48.0
Changelog:
- Adicionado endpoint POST /v2/transactions/batch
- Refatorado cliente do Ledger (pool de conexoes movido para nova biblioteca interna)
- Bump de psycopg 3.1.18 -> 3.2.0
- Reduzido timeout do Ledger de 5s para 2s
```

**Métricas Beacon (últimos 30 min):**

```
timestamp                p99_latency_ms   req_rate_s   err_rate_pct
2026-04-24 13:30 UTC     420              1200         0.2
2026-04-24 13:45 UTC     510              1450         0.3
2026-04-24 14:00 UTC     780              1780         0.8
2026-04-24 14:10 UTC     2400             2100         4.5
2026-04-24 14:15 UTC     5200             2400         8.2
2026-04-24 14:20 UTC     8100             2650         11.7
```

**Logs (pod chronos-api-79c4d8b9-xk2jp):**

```
2026-04-24 14:19:48 [ERROR] [ledger-client] connection pool exhausted (max=20, active=20, waiting=147)
2026-04-24 14:19:49 [WARN]  [ledger-client] query timeout after 2000ms: SELECT ... FROM transactions WHERE ...
2026-04-24 14:19:49 [ERROR] [handler] POST /v2/transactions/batch failed: context deadline exceeded
2026-04-24 14:19:50 [ERROR] [ledger-client] connection reset by peer
2026-04-24 14:19:51 [WARN]  [circuit-breaker] ledger-client OPEN (threshold 50%, current 87%)
2026-04-24 14:19:52 [ERROR] [reactor] failed to publish message: chronos-api upstream error
```

**Reactor (fila chronos-transactions):** 50.127 mensagens, +~800/min, lag **18 min** e crescendo.

**Cluster:** Chronos 12/12 pods (HPA max), CPU 62%, memória 71%, **conexões Ledger 240/250** (limite RDS).

## [ACTION]

1. Correlacionar timeline: deploy → tráfego → latência/erros → pool/timeout → circuit breaker → lag Reactor.
2. Ranquear hipóteses de causa raiz (primary + contributing factors).
3. Comparar opções **A (rollback)** vs **B (scaling)** com prós, contras e riscos **neste incidente**.
4. Emitir **recomendação clara** para Doc Brown (uma opção primária + ações imediatas).

## [RESULT]

Postmortem técnico em markdown (PT-BR) com:

- Recomendação fundamentada (rollback **ou** scaling)
- 3 ações imediatas acionáveis (bullets)
- Evidências citadas dos artefatos

## [EXAMPLE]

Use esta estrutura de seções:

```
1. Resumo executivo
2. Impacto observado
3. Linha do tempo
4. Causa raiz (provável)
5. Fatores contribuintes
6. Análise: Rollback vs. Scaling emergencial
7. Decisão recomendada
8. Ações imediatas (3)
9. Follow-ups pós-incidente
```

## [FORMAT]

- Documento markdown completo, PT-BR.
- Tabelas onde facilitar comparação A vs B.
- Tom técnico, direto — audience: CTO em war room.
