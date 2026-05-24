# Output — Q05

> **Status:** concluído  
> **Manifest gerado:** [deployment-chronos-modern.yaml](./deployment-chronos-modern.yaml)

Resposta do Composer 2.5 ao prompt BAB.

---

## Manifest modernizado

Ver arquivo completo: [`deployment-chronos-modern.yaml`](./deployment-chronos-modern.yaml)

### Transformações aplicadas (Before → After)

| Item | Before | After |
|------|--------|-------|
| Réplicas | 1 | 3 |
| Imagem | `chronos-api:latest` | `chronos-api:2.48.0` |
| Secrets | plain text no env | `secretKeyRef` → `chronos-api-secrets` |
| Resources | ausente | requests 250m/512Mi, limits 1 CPU/1Gi |
| Probes | ausente | liveness `/health`, readiness `/ready` |
| Security | ausente | non-root (UID 10001), drop ALL caps, readOnlyRootFilesystem |
| Strategy | default | RollingUpdate, maxUnavailable: 0 |

---

## Assumptions

- Secret `chronos-api-secrets` com keys `db-password` e `jwt-secret` já existe no namespace `production` (criado via Sealed Secrets / External Secrets — fora do escopo deste manifest).
- App expõe rotas `/health` e `/ready` na porta 8080.
- Tag `2.48.0` alinhada ao deploy citado no cenário Q08 (Chronos).
