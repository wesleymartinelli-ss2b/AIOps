# Runbook — High memory usage on Chronos API pods

| Campo | Valor |
|-------|--------|
| **Alerta** | `[CRITICAL] High memory usage on Chronos API pods (>85% for 10min)` |
| **Serviço** | Chronos API |
| **Namespace** | `production` |
| **Canal** | `#oncall-chronos` |
| **Escalação** | `@chronos-core` |
| **Tempo alvo** | ≤ 40 min |

---

## Pré-requisitos

- Acesso `kubectl` ao cluster EKS de produção
- `aws cli` e `argocd cli` autenticados
- Acesso ao Grafana (Beacon) e logs centralizados

---

## Passo 0 — Acknowledge e contexto (0–3 min)

**Ação:** Assumir o alerta e registrar início no Slack.

**Comando / ação:**

```text
# Slack #oncall-chronos
🚨 Assumindo incidente — High memory Chronos API — plantonista: [seu nome] — início: [HH:MM UTC]
```

**Verificação esperada:** Mensagem postada; alerta marcado como acknowledged no Beacon (se aplicável).

**Se falhar:** Escalar `@chronos-core` imediatamente se não houver acesso ao Slack/canal.

---

## Passo 1 — Snapshot do estado dos pods (3–8 min)

**Ação:** Confirmar quais pods estão acima de 85% de memória e se o problema é generalizado.

**Comandos:**

```bash
kubectl get pods -n production -l app=chronos-api -o wide

kubectl top pods -n production -l app=chronos-api --sort-by=memory

kubectl get hpa -n production
```

**Verificação esperada:**

| Sinal | Interpretação |
|-------|----------------|
| 1–2 pods acima de 85% | Possível pod “quente” ou leak localizado |
| Maioria ou todos > 85% | Carga sistêmica, config ou dependência |
| HPA em `maxReplicas` (12) | Pressão de escala já no teto |

**Se falhar:** Erro de auth/cluster → escalar `@chronos-core` (bloqueio de acesso).

---

## Passo 2 — Eventos recentes e restarts (8–12 min)

**Ação:** Verificar OOMKills, restarts e eventos do namespace.

**Comandos:**

```bash
kubectl describe pods -n production -l app=chronos-api | grep -A5 -E "State:|Last State:|Reason:|Restart Count"

kubectl get events -n production --sort-by='.lastTimestamp' | grep chronos-api | tail -20
```

**Verificação esperada:**

- `Restart Count` estável → memória alta sem crash ainda
- `OOMKilled` presente → priorizar mitigação imediata (Passo 5 ou 6)

**Se falhar:** —

---

## Passo 3 — Logs e métricas (12–18 min)

**Ação:** Diferenciar leak de memória vs. pico de tráfego vs. dependência lenta.

**Comandos:**

```bash
# Logs últimos 15 min (pod mais consumidor)
POD=$(kubectl top pods -n production -l app=chronos-api --sort-by=memory --no-headers | head -1 | awk '{print $1}')
kubectl logs -n production "$POD" --since=15m | tail -100

# Métricas in-cluster (se port-forward disponível)
kubectl port-forward -n production "$POD" 8080:8080 &
curl -s localhost:8080/metrics | grep -E "process_resident_memory|http_requests"
```

**Grafana (Beacon):** dashboard Chronos — painéis **memory**, **request rate**, **p99 latency**, **error rate** (últimos 30 min).

**Verificação esperada:**

| Padrão | Provável causa |
|--------|----------------|
| Memória sobe linearmente com tempo, RPS estável | Memory leak — considerar rollback (Passo 6) |
| Memória correlaciona com RPS / batch endpoint | Carga legítima — scale/out ou tuning HPA |
| Erros `ledger-client`, timeout, pool exhausted | Dependência Ledger — Passo 4 |

**Se falhar:** Sem acesso a logs/Grafana após 5 min → documentar no Slack e seguir Passo 4.

---

## Passo 4 — Dependências Ledger e Reactor (18–25 min)

**Ação:** Descartar pressão vinda de PostgreSQL ou filas SQS.

**Comandos:**

```bash
# Ledger — conexões/latência via logs Chronos
kubectl logs -n production -l app=chronos-api --since=15m | grep -iE "ledger|timeout|pool" | tail -30

# Reactor — lag de fila (ajuste nome da fila se necessário)
aws sqs get-queue-attributes \
  --queue-url "$(aws sqs get-queue-url --queue-name chronos-transactions --query QueueUrl --output text)" \
  --attribute-names ApproximateNumberOfMessages ApproximateAgeOfOldestMessage \
  --region us-east-1
```

**Verificação esperada:**

| Sinal | Ação |
|-------|------|
| Pool exhausted / timeout Ledger | Escalar `@chronos-core` + mencionar possível incidente Ledger (não resolver DB sozinho) |
| Lag SQS > 10 min e crescendo | Correlacionar com erros upstream; escalar se lag > 15 min |
| Dependências normais | Prosseguir mitigação memória (Passo 5) |

**Se falhar:** `aws sqs` sem permissão → registrar e escalar com evidência kubectl/logs.

---

## Passo 5 — Mitigação: rolling restart controlado (25–32 min)

**Ação:** Aliviar pods com memória alta **se** não houver sinal de leak pós-deploy recente e dependências OK.

**Comandos:**

```bash
kubectl rollout restart deployment/chronos-api -n production
kubectl rollout status deployment/chronos-api -n production --timeout=300s
kubectl top pods -n production -l app=chronos-api --sort-by=memory
```

**Verificação esperada:**

- Rollout `successfully rolled out`
- Memória dos pods < **75%** em até 10 min após restart

**Se falhar:**

- Rollout travado → `kubectl describe` + escalar `@chronos-core`
- Memória volta a > 85% em < 10 min → tratar como leak; ir para Passo 6

---

## Passo 6 — Rollback via Argo CD (se leak ou restart ineficaz) (32–38 min)

**Ação:** Reverter para revisão estável anterior no Argo CD.

**Comandos:**

```bash
argocd app history chronos-api --grpc-web
# Identificar revisão estável anterior (ex.: rev N-1)

argocd app rollback chronos-api <REVISION_ID> --grpc-web
kubectl rollout status deployment/chronos-api -n production --timeout=300s
kubectl top pods -n production -l app=chronos-api
```

**Verificação esperada:** Memória estabiliza < 80% por 10 min; error rate normalizado no Grafana.

**Se falhar:** Rollback não autorizado ou falha → **escalar `@chronos-core` imediatamente** (SLA 15/30 min).

---

## Critérios de escalação para `@chronos-core`

Escalar **agora** se **qualquer** item for verdadeiro:

| # | Critério |
|---|----------|
| 1 | OOMKill em ≥ 2 pods ou crash loop |
| 2 | Memória > 85% em ≥ 75% dos pods após Passo 5 |
| 3 | Evidência de Ledger (pool exhausted, RDS no limite) |
| 4 | Rollback Argo CD falhou ou indisponível |
| 5 | Tempo decorrido > 30 min sem mitigação |
| 6 | Error rate > 5% ou p99 latency > 2× baseline (Grafana) |

**Mensagem template Slack:**

```text
⬆️ Escalação @chronos-core — Chronos high memory
Evidência: [pods X/Y >85% | OOMKilled | ledger timeout | rollback falhou]
Ações tentadas: [passos 0–N]
Preciso de: [rollback approval | RDS scale | análise leak v2.48.0]
```

---

## Critérios de encerramento do incidente

Incidente **resolvido** quando **todos** por ≥ **15 minutos**:

| # | Critério |
|---|----------|
| 1 | Memória média dos pods Chronos **< 75%** |
| 2 | Nenhum pod em CrashLoopBackOff ou OOMKilled |
| 3 | Error rate **< 1%** (Grafana) |
| 4 | HPA entre min (4) e max (12) sem oscilação anormal |
| 5 | Sem lag crítico no Reactor (< 5 min) |

---

## Checklist final de encerramento

- [ ] Postar resolução no `#oncall-chronos` com causa provável e ações tomadas
- [ ] Atualizar ticket/incidente no Beacon
- [ ] Se rollback executado: registrar revisão Argo CD
- [ ] Se escalação ocorreu: confirmar handoff com `@chronos-core`
- [ ] Abrir follow-up se causa raiz não confirmada (ex.: leak em v2.48.0)

**Template resolução Slack:**

```text
✅ Resolvido — High memory Chronos API
Duração: [X min] | Causa provável: [carga / leak / dependência]
Ação: [restart / rollback rev X / escalação]
Memória atual: [Y% avg] | Monitorar próximos 30 min
```

---

## Referências rápidas

| Recurso | Valor |
|---------|--------|
| Repo Argo CD | `hvt/chronos-api` |
| HPA | min 4, max 12, CPU 70% |
| Métricas | `/metrics` |
| Dashboard | Grafana / Beacon — Chronos |
