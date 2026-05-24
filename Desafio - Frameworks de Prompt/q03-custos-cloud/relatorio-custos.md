# Relatório de redução de custos cloud — Hill Valley Tech

**Para:** Goldie Wilson (CEO)  
**De:** Análise inicial Doc Brown / time técnico  
**Período de referência:** último mês (breakdown AWS)  
**Meta:** −15% de custo cloud no trimestre, sem degradar SLA  

---

## Síntese executiva

| Métrica | Valor |
|---------|------:|
| Custo mensal total (AWS) | **USD 41.800** |
| Meta 15% (economia necessária) | **USD 6.270/mês** |
| Economia estimada (pacote recomendado) | **USD 6.500/mês** |
| % da conta | **15,6%** |

O pacote priorizado abaixo atinge a meta com ações de esforço predominantemente **baixo a médio**, concentradas em compute subutilizado, observabilidade e rede. Itens de **alto esforço** (consolidação EKS) ficam como aceleradores opcionais.

---

## Oportunidades priorizadas

<table>
  <thead>
    <tr>
      <th align="left"><img width="40" height="1" alt="" /><br />#</th>
      <th align="left"><img width="220" height="1" alt="" /><br />Oportunidade</th>
      <th align="left"><img width="100" height="1" alt="" /><br />Economia (USD/mês)</th>
      <th align="left"><img width="80" height="1" alt="" /><br />% conta</th>
      <th align="left"><img width="80" height="1" alt="" /><br />Esforço</th>
      <th align="left"><img width="280" height="1" alt="" /><br />Riscos / pré-requisitos</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>1</td>
      <td><strong>Compute Savings Plans / RI</strong> para EC2 on-demand (45% uso médio)</td>
      <td>2.000</td>
      <td>4,8%</td>
      <td>Médio</td>
      <td>Compromisso 1–3 anos; mapear workloads estáveis vs. variáveis; não cobrir burst imprevisível.</td>
    </tr>
    <tr>
      <td>2</td>
      <td><strong>RDS Reserved Instances</strong> (PostgreSQL multi-AZ, 62% uso)</td>
      <td>1.500</td>
      <td>3,6%</td>
      <td>Médio</td>
      <td>Compromisso de capacidade; validar sizing com Lorraine/SRE antes de RI full.</td>
    </tr>
    <tr>
      <td>3</td>
      <td><strong>CloudWatch Logs:</strong> retenção 90 → 30 dias + filtros de ingestão</td>
      <td>1.100</td>
      <td>2,6%</td>
      <td>Baixo</td>
      <td>Alinhar com Beacon/compliance (Strickland); manter retenção longa só para audit logs.</td>
    </tr>
    <tr>
      <td>4</td>
      <td><strong>Consolidar NAT Gateways</strong> (3 → 1–2) + VPC endpoints (S3, DynamoDB se aplicável)</td>
      <td>600</td>
      <td>1,4%</td>
      <td>Médio</td>
      <td>Redesenho de rede; testar latência entre AZs; janela de manutenção.</td>
    </tr>
    <tr>
      <td>5</td>
      <td><strong>Rightsizing EC2 on-demand</strong> (instâncias oversized, 45% uso médio)</td>
      <td>800</td>
      <td>1,9%</td>
      <td>Baixo</td>
      <td>Usar métricas do Beacon 30d; load test antes de downsize em produção.</td>
    </tr>
    <tr>
      <td>6</td>
      <td><strong>S3 Intelligent-Tiering / lifecycle</strong> (5 buckets, dados frios)</td>
      <td>500</td>
      <td>1,2%</td>
      <td>Baixo</td>
      <td>Classificar buckets; não aplicar lifecycle agressivo em dados de backup Ledger.</td>
    </tr>
    <tr>
      <td>7</td>
      <td><strong>Otimizar Data Transfer</strong> (tráfego entre regiões)</td>
      <td>400</td>
      <td>1,0%</td>
      <td>Médio</td>
      <td>Cache regional, replicação S3 cross-region review; impacto em DR se mal planejado.</td>
    </tr>
    <tr>
      <td>8</td>
      <td><strong>ElastiCache rightsizing</strong> (40% uso médio)</td>
      <td>400</td>
      <td>1,0%</td>
      <td>Baixo</td>
      <td>Monitorar hit rate e latência p99 após redução de nós.</td>
    </tr>
    <tr>
      <td>9</td>
      <td><strong>Consolidar cluster EKS não-prod</strong> (3 → 2 clusters)</td>
      <td>1.200</td>
      <td>2,9%</td>
      <td>Alto</td>
      <td>Isolamento dev/staging; RBAC e quotas; risco de noisy neighbor — fase 2 do trimestre.</td>
    </tr>
  </tbody>
</table>

---

## Pacote recomendado para meta 15%

| Fase | Oportunidades | Economia | Acumulado |
|------|---------------|----------|-----------|
| **Q1 imediato** (0–30 dias) | #3, #5, #6, #8 | USD 2.800 | 6,7% |
| **Q1 curto** (30–60 dias) | #1, #2, #4, #7 | USD 4.500 | 17,4%* |
| **Opcional** | #9 (EKS) | +USD 1.200 | 20,3%* |

\*Acumulado considera sobreposição parcial evitada — **pacote realista sem #9: USD 6.500 (15,6%)**.

Itens **#1 + #2 + #3 + #5** sozinhos somam **USD 5.400 (12,9%)**; incluir **#4 + #6 + #8** fecha a meta.

---

## Riscos globais à meta

- **SLA:** nenhuma ação recomendada no pacote imediato altera multi-AZ do RDS ou réplicas mínimas do Chronos.
- **Compliance:** retenção de logs exige validação com Strickland antes de cortar 90 → 30 dias.
- **Compromissos financeiros:** Savings Plans/RI exigem previsibilidade de carga — Doc Brown deve validar forecast trimestral.

---

## Próximos passos sugeridos

1. Aprovar pacote fase imediata (#3, #5, #6, #8) — **baixo risco, ~USD 2.800/mês**.
2. Iniciar análise de compromissos compute/DB (#1, #2) com financeiro — **até +USD 3.500/mês**.
3. Revisar arquitetura de rede (#4) em workshop SRE — **+USD 600/mês**.
4. Avaliar consolidação EKS (#9) como stretch goal se meta precisar de margem extra.

---

*Valores estimados com base no CSV fornecido; refinamento com Cost Explorer e tags CostCenter recomendado.*
