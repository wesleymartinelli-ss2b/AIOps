# syntax=docker/dockerfile:1

# Production image for Lift API (Flask + gunicorn)
FROM python:3.12-slim AS runtime

# Prevent Python from writing .pyc files and buffer stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

# Runtime deps for psycopg2-binary (libpq)
RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies first (layer cache)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Application code
COPY app.py .
COPY lib/ ./lib/

# Non-root user
RUN groupadd --system lift \
    && useradd --system --gid lift --home-dir /app --no-create-home lift \
    && chown -R lift:lift /app
USER lift

# Required at runtime (inject via Kubernetes Secrets / ConfigMap)
ENV DATABASE_URL="" \
    API_KEY=""

EXPOSE 8080

# TCP check on app port (no /health endpoint assumed)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import socket; s=socket.create_connection(('127.0.0.1', 8080), 2); s.close()" || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "4", "app:app"]
