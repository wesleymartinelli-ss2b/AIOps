# Prompt — Q05 Deployment Chronos modernizado

> **Status:** concluído  
> **Framework:** BAB

---

## [BEFORE] — Manifest legado (estado atual)

Este é o Deployment do **Chronos API** em produção, escrito há 3 anos, sem revisão desde então:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chronos-api
  namespace: production
spec:
  replicas: 1
  selector:
    matchLabels:
      app: chronos-api
  template:
    metadata:
      labels:
        app: chronos-api
    spec:
      containers:
      - name: api
        image: chronos-api:latest
        ports:
        - containerPort: 8080
        env:
        - name: DB_PASSWORD
          value: "P@ssw0rd2023!"
        - name: JWT_SECRET
          value: "hvt-jwt-prod-secret"
```

**Problemas identificados:** single point of failure (1 réplica), tag `latest`, secrets em plain text no manifest, sem resources, probes ou hardening de segurança.

## [AFTER] — Estado desejado (padrão HVT produção)

O manifest modernizado deve atender:

- **Alta disponibilidade:** múltiplas réplicas + `RollingUpdate` seguro (`maxUnavailable: 0`)
- **Imagem versionada** (ex.: `chronos-api:2.48.0`) — **proibido `latest`**
- **Secrets fora do manifest** via `secretKeyRef` (Secret `chronos-api-secrets` — não criar o Secret, só referenciar)
- **Resources:** `requests` e `limits` de CPU/memória
- **Probes:** `livenessProbe` e `readinessProbe` HTTP (paths `/health` e `/ready`)
- **Security:** pod e container `securityContext` non-root, `runAsNonRoot`, drop capabilities, `allowPrivilegeEscalation: false`
- Manter `name`, `namespace`, labels `app: chronos-api`

## [BRIDGE] — Instruções de transformação

Modernize o manifest **Before → After**:

1. Preserve identidade (`chronos-api`, `production`, selector/labels).
2. Substitua env literals por `secretKeyRef`.
3. Adicione todos os requisitos **After** ausentes no legado.
4. Comentários **en_US** apenas onde houver decisão de segurança ou operação.
5. Entregue **um único YAML** válido, pronto para `kubectl apply`.

## [FORMAT]

- Apenas o manifest Kubernetes em bloco `yaml`.
- Sem explicações longas fora do arquivo.
