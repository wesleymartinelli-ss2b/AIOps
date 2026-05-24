# Justificativa — Q08 (CARE + comparação estendida)

> **Status:** concluído

## Framework escolhido: CARE

| Componente | Onde aparece no prompt |
|------------|------------------------|
| **Context** | Seção `[CONTEXT]`: deploy v2.48.0 + changelog, tabela de métricas, logs, estado Reactor e cluster, decisão pendente rollback vs. scaling em 20 min — **todos os artefatos** do enunciado. |
| **Action** | Seção `[ACTION]`: correlacionar timeline, ranquear hipóteses, comparar A vs B, emitir recomendação — **como analisar**. |
| **Result** | Seção `[RESULT]`: postmortem com recomendação clara + 3 ações imediatas — **entrega esperada**. |
| **Example** | Seção `[EXAMPLE]`: esqueleto de 9 seções (Resumo, Impacto, Timeline, Causa raiz, …) — **formato do documento**. |

### Por que CARE é o melhor fit

O enunciado entrega **contexto denso e heterogêneo** (deploy, métricas, logs, fila, cluster) e pede um **documento estruturado** com **decisão executiva**. CARE separa claramente:

- ingestão de contexto (Context),
- trabalho analítico (Action),
- deliverable (Result),
- moldura reutilizável (Example).

Isso espelha a Q06 (padrão compliance + exemplo VPC) — análise complexa com template de saída.

---

## Comparação com alternativas

### vs. BAB (Before · After · Bridge)

| | |
|-|-|
| **O que se ganharia** | Narrativa clara **estado saudável (13:30) → estado degradado (14:20) → ponte (rollback ou scale)**; fácil para CTO visualizar transformação A→B. |
| **O que se perderia** | BAB não estrutura **5 fontes de evidência simultâneas** (deploy, métricas, logs, SQS, cluster); tende a oversimplificar causa raiz multi-fator; Example de postmortem com 9 seções não é natural em BAB. |

**Veredicto:** BAB seria forte para **comunicar remediação**, fraco para **forensics correlacional** pedida aqui.

---

### vs. RISE (Role · Input · Steps · Expectation)

| | |
|-|-|
| **O que se ganharia** | Procedimento de war room passo a passo (já coberto na Q07); Role de analista de incidente; Expectation de decisão em 20 min operacionalizada em Steps. |
| **O que se perderia** | RISE orienta **execução**, não **síntese analítica**; comparar rollback vs. scaling com tabela de trade-offs e linha do tempo correlacionada ficaria artificial em “Steps”; Example de postmortem executivo não é o forte do RISE. |

**Veredicto:** RISE = runbook/plantão (Q07). Q08 exige **postmortem + decisão estratégica** → CARE superior.

---

### Outros frameworks (breve)

| Framework | Por que não |
|-----------|-------------|
| **RTF** | Tarefa não é artefato único simples; contexto extenso não cabe bem em Role+Task+Format. |
| **TAG** | Goal (decisão rollback vs scale) é central, mas **falta Example** para estrutura de postmortem e **Context** explícito para artefatos múltiplos. |

---

## Conclusão

**CARE** equilibra **contexto denso**, **análise estruturada** e **template de postmortem** — requisitos da Q08. **BAB** e **RISE** seriam escolhas válidas em cenários adjacentes (comunicação de remediação e procedimento operacional), mas **perdem profundidade analítica** ou **formato executivo** exigidos para Doc Brown decidir em 20 minutos.
