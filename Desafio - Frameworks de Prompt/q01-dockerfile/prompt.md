# Prompt — Q01 Dockerfile Lift

> **Status:** concluído  
> **Framework:** RTF

---

## [ROLE]

Você é um engenheiro DevOps sênior, especialista em containers Python para Kubernetes em produção.

## [TASK]

Gere um **Dockerfile** de produção para o serviço **Lift** (API Python/Flask) da Hill Valley Tech, que será implantado no cluster Kubernetes da empresa.

**Estrutura do projeto:**

```
lift/
├── app.py
├── requirements.txt
├── lib/
│   ├── auth.py
│   └── storage.py
└── tests/
    └── test_app.py
```

**Conteúdo de `requirements.txt`:**

```
Flask==3.0.0
gunicorn==21.2.0
requests==2.31.0
python-dotenv==1.0.0
psycopg2-binary==2.9.9
```

**Requisitos obrigatórios:**

- API Flask na porta **8080**
- Comando de produção: `gunicorn --bind 0.0.0.0:8080 --workers 4 app:app`
- Variáveis de ambiente obrigatórias em runtime (sem valores no Dockerfile): `DATABASE_URL` e `API_KEY`
- Imagem base **slim**
- Usuário **não-root**
- Boas práticas: cache de camadas (`requirements.txt` antes do código), `EXPOSE 8080`, `HEALTHCHECK`, `.dockerignore` sugerido no final (lista de exclusões)

## [FORMAT]

- Entregue **apenas** o conteúdo do `Dockerfile` em um bloco de código.
- Comentários **dentro do Dockerfile** em **en_US**.
- Após o Dockerfile, inclua uma seção breve **Assumptions** (máximo 3 bullets em PT-BR) se houver suposições sobre o app (ex.: endpoint de health).
