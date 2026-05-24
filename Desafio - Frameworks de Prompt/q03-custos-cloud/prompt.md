# Prompt — Q03 Relatório custos cloud

> **Status:** concluído  
> **Framework:** TAG

---

## [TASK]

Analise o breakdown de custos AWS do último mês da Hill Valley Tech (CSV abaixo) e identifique oportunidades concretas de redução de gastos cloud, sem degradar SLA de produção.

**CSV de custos (USD/mês):**

```csv
servico,categoria,custo_mensal_usd,uso_medio_pct,observacao
EC2 reservada,compute,4200,72,contrato de 1 ano
EC2 on-demand,compute,8200,45,workloads variaveis
EKS,compute,6700,58,3 clusters
RDS PostgreSQL,databases,8200,62,multi-AZ
ElastiCache Redis,databases,2100,40,cluster de producao
S3 Standard,storage,3100,,5 buckets principais
EBS gp3,storage,1600,68,volumes de producao
CloudWatch Logs,observability,2800,,retencao de 90 dias
CloudWatch Metrics,observability,900,,
Data Transfer Out,network,1900,,trafego entre regioes
NAT Gateway,network,1200,,3 gateways ativos
Lambda,compute,900,30,~12M invocacoes/mes
```

## [ACTION]

1. Calcule o **custo total mensal** da conta.
2. Liste oportunidades de economia **priorizadas por impacto** (USD/mês decrescente).
3. Para cada oportunidade, informe: economia estimada (USD), **% da conta total**, esforço (**baixo / médio / alto**), riscos e pré-requisitos.
4. Estime a **economia acumulada** se as principais ações forem executadas no trimestre.
5. Apresente em **markdown**, PT-BR, com tabela principal e síntese executiva.

## [GOAL]

Entregar um relatório executivo para **Goldie Wilson (CEO)** com recomendações acionáveis que suportem a meta de **15% de redução** no custo cloud até o fim do trimestre, **sem comprometer SLA**.
