# Prompt — Q07 Runbook memória Chronos

> **Status:** concluído  
> **Framework:** RISE

---

## [ROLE]

Você é um **autor de runbooks SRE** especializado em incidentes Kubernetes/EKS. Seu público é o **plantonista de turno** que pode não conhecer o Chronos em profundidade — o texto deve ser procedural, objetivo e acionável.

## [INPUT]

**Alerta recorrente (Beacon / Slack):**

```
[CRITICAL] High memory usage on Chronos API pods (>85% for 10min)
```

**Ambiente:**

| Item | Detalhe |
|------|---------|
| Serviço | Chronos API |
| Cluster | EKS, namespace `production` |
| Réplicas | 6 (HPA: min 4, max 12, target CPU 70%) |
| Deploy | Argo CD, repo `hvt/chronos-api` |
| Dependências | Ledger (PostgreSQL), Reactor (filas SQS) |
| Observabilidade | `/metrics`, logs no Beacon, dashboards Grafana |
| Ferramentas | `kubectl`, `aws cli`, `argocd cli` |
| Canal plantão | `#oncall-chronos` (Slack) |
| Escalação | `@chronos-core` — SLA 15 min (comercial) / 30 min (fora) |

**Problema:** plantonistas levam 30–40 min sem procedimento documentado; Lorraine (SRE) exige runbook de ponta a ponta.

## [STEPS]

O runbook deve incluir seções numeradas com, **em cada passo**:

1. **Ação** (o que fazer)
2. **Comando(s)** específicos (`kubectl`, `aws`, `argocd` quando aplicável)
3. **Verificação esperada** (como saber se o passo deu certo)
4. **Se falhar** (próximo caminho ou escalação parcial)

Cobrir no mínimo:

- Triagem inicial e acknowledge no Slack
- Inspeção de pods, memória e HPA
- Análise de logs e métricas (memory leak vs. carga vs. dependência)
- Verificação Ledger (conexões/latência) e Reactor (lag SQS)
- Ações de mitigação (restart rolling, scale HPA, rollback Argo CD se indicado)
- Critérios objetivos para escalar `@chronos-core`
- Critérios para **encerrar** o incidente

## [EXPECTATION]

- Formato **markdown**, **PT-BR** (comandos e paths em en_US)
- Tempo alvo de resolução: **≤ 40 minutos** seguindo o runbook
- Qualquer plantonista consegue executar **sem depender de conhecimento tribal**
- Incluir checklist final de encerramento e template de mensagem no `#oncall-chronos`

## [FORMAT]

Entregue o runbook completo em um único documento markdown.
