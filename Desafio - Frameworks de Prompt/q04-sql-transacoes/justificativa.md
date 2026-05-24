# Justificativa — Q04 (TAG)

> **Status:** concluído

| Componente | Onde aparece no prompt |
|------------|------------------------|
| **Task** | Seção `[TASK]`: schema DDL, regras de negócio (status, categorias, BRL, 6 meses, agrupamento, métricas, ordenação) — define **o que** a query deve entregar. |
| **Action** | Seção `[ACTION]`: 5 passos técnicos (filtro de datas, agrupamento YYYY-MM, COUNT/SUM, ORDER BY, formato de saída SQL) — define **como** construir a query. |
| **Goal** | Seção `[GOAL]`: SQL executável para Jennifer apresentar crescimento por categoria à Goldie — define **para quê** serve o resultado. |

TAG adequado porque o **objetivo** (relatório para PM/apresentação) guia a ação SQL; a task descreve as regras sem precisar de papel (Role) ou exemplo (CARE).
